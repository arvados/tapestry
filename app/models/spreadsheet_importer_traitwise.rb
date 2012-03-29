class SpreadsheetImporterTraitwise < SpreadsheetImporter
  belongs_to :spreadsheet
  belongs_to :traitwise_survey

  attr_protected :spreadsheet_id
  attr_protected :traitwise_survey_id

  def synchronize!(user,request,cookies)
    @traitwise_csv = Traitwise.report( nil, "survey_#{traitwise_survey.id}", nil, request, cookies, user )
    datarows = CSV.parse(@traitwise_csv)

    return false, 'No data' unless
        datarows and
        datarows.length > 0 and
        datarows[0] and
        datarows[0].length > 0

    header_row = datarows.shift
    spreadsheet.header_row = header_row
    spreadsheet.save
    success_count = 0
    attempt_count = 0
    hex_id_col = spreadsheet.header_row.index('Foreign Id')
    datarows.each do |r|
      # skip blank rows
      next if r == [nil]
      attempt_count += 1

      # save the row as a generic SpreadsheetRow object
      sr = SpreadsheetRow.where('spreadsheet_id = ? and row_number = ?', spreadsheet.id, r[0]).first
      if sr.nil? then
        sr = SpreadsheetRow.new(:row_number => r[0], :row_data => r)
        sr.spreadsheet = spreadsheet

        # link the row to the appropriate user
        if hex_id_col and
            (u = User.where('hex = ?', r[hex_id_col]).first)
          sr.row_target = u
        end
      end
      begin
        sr.save
      rescue
        nil
      end

      # save the row in the appropriate rowtarget object, if possible
      next unless (spreadsheet.rowtarget_type and
                   spreadsheet.rowtarget_id_attribute and
                   spreadsheet.rowtarget_data_attribute and
                   spreadsheet.row_id_column)

      target = find_target_by_id(r[row_id_column])
      if target and
          target.update_attributes "#{spreadsheet.rowtarget_data_attribute}".to_sym => hash
        success_count += 1
      end
    end

    spreadsheet.last_downloaded_at = Time.now()
    spreadsheet.save

    return true, ''
  end

end

