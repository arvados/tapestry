class SafetyQuestionnaire < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_inclusion_of :changes, :in => [ true, false ]
  validates_presence_of :datetime

end
