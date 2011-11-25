class Permission < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :granted_to, :class_name => 'User'
  belongs_to :granted_by, :class_name => 'User'

  validates_presence_of :action
  validates_presence_of :subject_class

 end
