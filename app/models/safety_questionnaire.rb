class SafetyQuestionnaire < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  validates_presence_of :user_id
  validates_inclusion_of :has_changes, :in => [ true, false ]
  validates_presence_of :datetime

end
