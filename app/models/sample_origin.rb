class SampleOrigin < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :parent_sample, :class_name => 'Sample'
  belongs_to :child_sample, :class_name => 'Sample'

  validates_presence_of :parent_sample_id
  validates_presence_of :child_sample_id
  validates_uniqueness_of :child_sample_id, :scope => :parent_sample_id
end
