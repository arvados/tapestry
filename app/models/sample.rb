class Sample < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :study
  belongs_to :kit
  belongs_to :original_kit_design_sample, :class_name => "KitDesignSample"
  belongs_to :kit_design_sample

  belongs_to :participant, :class_name => "User"
  belongs_to :owner, :class_name => "User"

  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :study_id
  validates_presence_of :kit_id

  scope :real, where('is_destroyed is ?',nil)
  scope :destroyed, where('is_destroyed is not ?',nil)

end
