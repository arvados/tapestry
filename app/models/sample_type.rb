class SampleType < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of    :name
  validates_uniqueness_of  :name

  validates_presence_of    :description
  validates_presence_of    :target_amount

  validates_presence_of    :tissue_type_id
  validates_presence_of    :device_type_id
  validates_presence_of    :unit_id

  belongs_to :tissue_type
  belongs_to :device_type
  belongs_to :unit
end
