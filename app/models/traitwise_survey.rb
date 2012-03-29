class TraitwiseSurvey < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  require 'uri'

  belongs_to :user
  has_one :spreadsheet_importer
  has_one :spreadsheet, :through => :spreadsheet_importer

  attr_protected :user_id
  attr_protected :spreadsheet_id

  CACHE_DIR = "/data/" + ROOT_URL + "/traitwise_surveys"

end
