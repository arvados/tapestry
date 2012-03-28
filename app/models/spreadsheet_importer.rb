class SpreadsheetImporter < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :spreadsheet

  attr_protected :spreadsheet_id
end
