class Spreadsheet < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :header_row, Array

  attr_protected :user_id

  belongs_to :user
  has_one :spreadsheet_importer, :dependent => :destroy

  has_many :spreadsheet_rows
end
