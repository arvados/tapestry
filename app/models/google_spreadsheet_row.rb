class GoogleSpreadsheetRow < ActiveRecord::Base
  stampable
  belongs_to :google_spreadsheet
  serialize :row_data
end
