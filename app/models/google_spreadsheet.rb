class GoogleSpreadsheet < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :header_row

  belongs_to :user
  belongs_to :oauth_service
  has_many :google_spreadsheet_rows

  attr_protected :last_downloaded_at
  attr_protected :user_id

  def get_token
    OauthToken.
      find_by_user_id_and_oauth_service_id(self.user.id,
                                           self.oauth_service.id)
  end

  def get_datarows
    return @datarows if @datarows
    return nil if !oauth_service

    token = get_token
    if token.nil? or !token.authorized?
      return nil, "I do not have authorization to get " +
        "#{self.user.full_name}'s data from #{self.oauth_service.name}."
    end

    parse_sheet_url rescue return nil, "Could not parse spreadsheet URL"

    uri = URI.parse("https://spreadsheets.google.com/feeds/download/" +
                    "spreadsheets/Export?key=#{@skey}&gid=#{@gid}")
    resp = token.oauth_request('GET', uri, {
                                 'format' => 'csv',
                                 'exportFormat' => 'csv'
                               })
    if resp.code != '200' or resp.body.nil?
      return nil, "Unexpected response from #{uri.to_s}" +
        " -- #{resp.code} #{resp.message} #{resp.body}"
    end
    @datarows = CSV.parse(resp.body)
  end

  def parse_sheet_url
    @skey = Regexp.
      new('^(.*key=)?([-_a-zA-Z0-9]+)([\&\#].*)?$').
      match(gdocs_url)[2]
    @gid = Regexp.
      new('[\&\#]gid=([0-9]+)(\&.*)?$').
      match(gdocs_url)[1] rescue 0
  end

  def guess_fields_from_feed
    guess_name
    guess_id_column
  end

  def guess_name
    return true if name and name.length > 0
    parse_sheet_url rescue return nil
    uri = URI.parse("https://spreadsheets.google.com/feeds/worksheets/" +
                    "#{@skey}/private/full")

    token = get_token
    return nil if !token or !token.authorized?

    resp = token.oauth_request('GET', uri, {})
    if resp.code != '200' or resp.body.nil?
      return nil, "Unexpected response from #{uri.to_s}" +
        " -- #{resp.code} #{resp.message} #{resp.body}"
    end
    p resp.body
    begin
      title = Regexp.
        new('<title[^>]*>([^<]+)</title>').
        match(resp.body)[1]
    rescue
      return nil
    end
    update_attributes(:name => title)
    true
  end

  def guess_id_column
    return true if row_id_column

    rows = get_datarows
    return nil unless rows.length > 1 and rowtarget_class

    target_class = rowtarget_class.constantize or return nil

    possible = Hash.new
    (0..rows[1].length-1).each { |c| possible[c] = 0 }
    (1..[8,rows.length-1].min).each do |r|
      possible.keys.each do |c|
        v = rows[r][c]

        # would be better to ask target_class what type id_attribute should be:
        v = v.to_i if v.class == String and Regexp.new('^[0-9]+$').match(v)

        if v
          ob = target_class.send("find_by_#{rowtarget_id_attribute}".to_sym,
                                 v)
          if ob
            possible[c] += 1
          end
        end
      end
    end
    possible.keys.each do |c|
      possible.delete c if possible[c] < possible.values.max
    end
    if possible.length == 1
      update_attributes :row_id_column => possible.keys[0]
    else
      nil
    end
  rescue
    nil
  end

  def synchronize!
    guess_id_column unless row_id_column

    datarows = get_datarows
    return nil unless
      datarows and
      datarows.length > 0 and
      datarows[0] and
      datarows[0].length > 0

    update_attributes :header_row => datarows[0]
    success_count = 0
    attempt_count = 0
    (1..datarows.length-1).each do |r|
      attempt_count += 1
      hash = Hash.new
      (0..datarows[0].length-1).each do |i|
        hash[datarows[0][i]] = datarows[r][i]
      end

      # save the row as a generic GoogleSpreadsheetRow object
      unless (GoogleSpreadsheetRow.
              new(:google_spreadsheet_id => self.id,
                  :row_number => attempt_count,
                  :row_data => datarows[r]).save rescue nil)
        g_s_r = GoogleSpreadsheetRow.
          find_by_google_spreadsheet_id_and_row_number(self.id, attempt_count)
        g_s_r.update_attributes :row_data => datarows[r]
      end

      # save the row in the appropriate rowtarget object, if possible
      next unless (rowtarget_class and
                   rowtarget_id_attribute and
                   rowtarget_data_attribute and
                   row_id_column)

      target = find_target_by_id(datarows[r][row_id_column])
      if target and
          target.update_attributes "#{rowtarget_data_attribute}".to_sym => hash
        success_count += 1
      end
    end
    GoogleSpreadsheetRow.
      where("google_spreadsheet_id = ? and row_number > ?",
            self.id, attempt_count).
      delete_all
    self.last_downloaded_at = Time.now
    save
    return success_count, attempt_count
  end

  def find_target_by_id(id_from_row)
    rowtarget_class.
      constantize.
      send("find_by_#{rowtarget_id_attribute}".to_sym, id_from_row)
  rescue
    nil
  end

end
