class RemovalRequest < ActiveRecord::Base
  model_stamper
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version
  belongs_to :user

  belongs_to :fulfilled_by, :class_name => 'User', :foreign_key => 'fulfilled_by'
end
