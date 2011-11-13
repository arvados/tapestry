class Permission < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  validates_presence_of :action
  validates_presence_of :subject_class

 end
