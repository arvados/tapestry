class InformedConsentResponse < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  attr_protected :user_id
  validates_presence_of :user_id
  validates_inclusion_of :twin,      :in => [0, 1, 2], :message => 'must be Yes, No or Unsure'
  validates_inclusion_of :recontact, :in => [0, 1], :message => 'must be Yes or No'
end
