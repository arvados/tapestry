class SpreadsheetRow < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  attr_protected :spreadsheet_id

  belongs_to :row_target, :polymorphic => true
  belongs_to :spreadsheet
  serialize :row_data

  validates_uniqueness_of :row_number, :scope => :spreadsheet_id
end
