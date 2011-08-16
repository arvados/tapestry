class PlateSample < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :plate
  belongs_to :plate_layout_position
  belongs_to :sample

  validates_uniqueness_of :plate_layout_position_id, :scope => :plate_id
  validates_presence_of :plate
  validates_presence_of :plate_layout_position
end
