class GoogleSurvey < ActiveRecord::Base
  require 'uri'

  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :oauth_service

  attr_protected :last_downloaded_at
  attr_protected :user_id

  CACHE_DIR = "/data/" + ROOT_URL + "/google_surveys"

  def responses
    Nonce.used.where('owner_class = ? and target_class = ? and target_id = ?',
                     'User', self.class.to_s, self.id)
  end

  def self.create_legacy_nonces!
    added = 0
    default_survey = GoogleSurvey.where(:open => true)[0] rescue return
    logre = Regexp.new('^Clicked through to participant survey: (\S+) -> (hu[A-F0-9]+)')
    UserLog.where("comment like '%Clicked through to participant survey:%'").each do |log|
      (md5, huID) = logre.match(log.comment)[1..2] rescue next
      next if !log.user or log.user.hex != huID
      nonce = Nonce.new(:created_at => log.created_at,
                        :owner_class => log.user.class.to_s,
                        :owner_id => log.user.id,
                        :target_class => default_survey.class.to_s,
                        :target_id => default_survey.id,
                        :nonce => md5)
      begin
        nonce.save!
        logger.info "Added nonce #{nonce.nonce} for user ##{log.user.id} #{log.user.hex}"
        added += 1
      rescue ActiveRecord::RecordInvalid
      end
    end
    added
  end

  def synchronize!
    token = OauthToken.find_by_user_id_and_oauth_service_id(self.user.id, self.oauth_service.id)
    if token.nil? or !token.authorized?
      return nil, "I do not have authorization to get #{self.user.full_name}'s data from #{self.oauth_service.name}."
    end

    begin
      skey = Regexp.new('^(.*key=)?([-_a-zA-Z0-9]+)(\&.*)?$').match(self.spreadsheet_key)[2]
    rescue
      return nil, "Could not parse spreadsheet URL"
    end

    uri = 'https://spreadsheets.google.com/feeds/download/spreadsheets/Export'
    resp = token.oauth2_request('GET', uri,
                                'key' => skey,
                                'exportFormat' => 'csv')
    if resp.status != 200 or resp.body.nil?
      return nil, "Unexpected response from #{uri} -- #{resp.status} #{resp.body}"
    end

    cache_file = "#{CACHE_DIR}/#{self.id}.csv"
    stamp = '.' + Time.now.to_i.to_s
    begin
      Dir.mkdir(CACHE_DIR) unless File.directory? CACHE_DIR
      File.open(cache_file+stamp,"w") { |f| f.write(resp.body); f.close }
      File.rename(cache_file+stamp, cache_file)
      self.last_downloaded_at = Time.now
      save
    rescue SystemCallError
      logger.error "Error writing CSV to #{cache_file}: #{$!}"
      begin
        File.delete(cache_file+stamp)
      rescue SystemCallError
      end
    end

    datarows = CSV.parse(resp.body)
    processed_datarows = []
    head = datarows.shift
    column = 0
    head.each do |q_text|
      column += 1
      q = GoogleSurveyQuestion.find_by_google_survey_id_and_column(self.id, column)
      if q.nil?
        q = GoogleSurveyQuestion.new(:google_survey => self, :column => column)
        if q.nil?
          return nil, "#{self.class} #{self.id} cannot find or create question for column #{column}.  Giving up."
        end
      end
      q.question = q_text
      q.save
    end
    head.unshift 'Participant'
    processed_datarows.push head

    nonce_column = nil
    datarow_count = 0
    processed_nonces = {}
    nonce_re = Regexp.new('^[0-9a-z]{24,}$')
    md5_re = Regexp.new('^[0-9a-f]{32}$')
    datarows.each do |row|
      processed_datarows.push row.clone
      processed_datarows[-1].unshift nil
      datarow_count += 1
      if nonce_column.nil?
        c = 0
        row.each do |value|
          c += 1
          if nonce_re.match(value) and Nonce.find_by_nonce(value)
            nonce_column = c
            break
          end
        end
      end
      nonce_value = nonce_column ? row[nonce_column-1] : nil
      nonce = nonce_value ? Nonce.find_by_nonce(nonce_value) : nil
      if nonce.nil?
        logger.info "Invalid nonce #{nonce_value} on data row #{datarow_count}."
        # Remove this row from the results. It is bogus because we can
        # not link it up to a nonce. It could be data that has been
        # marked "removed" in our database.
        processed_datarows.pop
        next
      elsif (nonce.owner_class != 'User' or
          nonce.target_class != 'GoogleSurvey' or
          nonce.target_id != self.id)
        logger.warn "Nonce #{nonce_value} for data row #{datarow_count} was not issued for this survey."
        processed_datarows.pop
        next
      elsif processed_nonces.has_key? nonce.id
        # This nonce had already been used when this response row was
        # added.  The nonce could have been published in the meantime,
        # so we can't be sure this response was entered by the
        # participant we issued the nonce to.
        processed_datarows.pop
        next
      end
      processed_nonces[nonce.id] = true

      u = User.find(nonce.owner_id)
      if u.nil?
        logger.warn "Nonce #{nonce_value} has non-existent user id ##{nonce.owner_id} as owner_id"
        next
      end

      processed_datarows[-1][0] = u.hex
      next if nonce.used_at

      column = 0
      row.each do |a_text|
        column += 1
        GoogleSurveyAnswer.new(:google_survey => self,
                               :nonce => nonce,
                               :column => column,
                               :answer => a_text).save
      end
      u.log("Retrieved GoogleSurvey ##{self.id} (#{self.name}) nonce #{nonce.nonce} timestamp #{row[0]}", nil, nil, "Retrieved results for survey: #{self.name}")
      nonce.use!
    end

    self.userid_response_column = nonce_column if nonce_column
    save

    begin
      CSV.open(processed_csv_file+stamp, 'wb') do |csv|
        processed_datarows.each { |row| csv << row }
        csv.close
      end
      File.rename processed_csv_file+stamp, processed_csv_file
    rescue SystemCallError
      logger.error "Error writing processed CSV to #{processed_csv_file}: #{$!}"
      begin
        File.delete(processed_csv_file+stamp)
      rescue SystemCallError
      end
    end

    datarows.size
  end

  def processed_csv_file
    "#{CACHE_DIR}/#{self.id}-with-huID.csv"
  end
end
