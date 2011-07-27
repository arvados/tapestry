class GoogleSurvey < ActiveRecord::Base
  require 'uri'

  belongs_to :user
  belongs_to :oauth_service

  attr_protected :last_downloaded_at
  attr_protected :user_id

  CACHE_DIR = "/data/" + ROOT_URL + "/google_surveys"

  def synchronize!
    token = OauthToken.find_by_user_id_and_oauth_service_id(self.user.id, self.oauth_service.id)
    if token.nil?
      flash[:error] = "I do not have authorization to get #{self.user.full_name}'s data from #{self.oauth_service.name}."
      return nil
    end
    skey = Regexp.new('^(.*key=)?([-_a-zA-Z0-9]+)(\&.*)?$').match(self.spreadsheet_key)[2]
    uri = URI.parse("https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=#{skey}")
    resp = token.oauth_request('GET', uri, {'format' => 'csv', 'exportFormat' => 'csv' })
    if resp.code != '200' or resp.body.nil?
      $stderr.puts "Unexpected response from #{uri.to_s} -- #{resp.code} #{resp.message} #{resp.body}"
      return nil
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
      $stderr.puts "Error writing CSV to #{cache_file}: #{$!}"
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
          $stderr.puts "#{self.class} #{self.id} cannot find or create question for column #{column}.  Giving up."
          return nil
        end
      end
      q.question = q_text
      q.save
    end
    head.unshift 'Participant'
    processed_datarows.push head

    nonce_column = nil
    datarow_count = 0
    tried_creating_legacy_nonces = false
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
          if !tried_creating_legacy_nonces and md5_re.match(value) and defined? SURVEY_SALT
            $stderr.puts "Creating legacy nonces"
            tried_creating_legacy_nonces = true
            User.all.each do |u|
              next unless u.hex and u.hex.length > 0
              nonce = Nonce.new(:created_at => Time.now,
                                :owner_class => u.class.to_s,
                                :owner_id => u.id)
              nonce.nonce = Digest::MD5.hexdigest(SURVEY_SALT + u.hex)
              begin
                nonce.save!
              rescue ActiveRecord::RecordInvalid
                # assume this legacy nonce has already been saved
              end
            end
            redo
          end
        end
      end
      nonce_value = nonce_column ? row[nonce_column-1] : nil
      nonce = nonce_value ? Nonce.find_by_nonce(nonce_value) : nil
      if nonce.nil?
        $stderr.puts "Invalid nonce #{nonce_value} on data row #{datarow_count}"
        next
      end
      processed_datarows[-1][0] = User.find(nonce.owner_id).hex
      next if nonce.used_at

      column = 0
      row.each do |a_text|
        column += 1
        GoogleSurveyAnswer.new(:google_survey => self,
                               :nonce => nonce,
                               :column => column,
                               :answer => a_text).save
      end
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
      $stderr.puts "Error writing processed CSV to #{processed_csv_file}: #{$!}"
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
