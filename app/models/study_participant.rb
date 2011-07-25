class StudyParticipant < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  belongs_to :study

  validates_presence_of     :user_id
  validates_presence_of     :study_id

  validates_inclusion_of    :status,      :in => [0, 1, 2, 3, 4, 5]

  scope :undecided, { :conditions => "status = 0" }
  scope :not_interested, { :conditions => "status = 1" }
  scope :interested, { :conditions => "status = 2" }
  scope :accepted, { :conditions => "status = 3" }
  scope :not_accepted, { :conditions => "status = 4" }
  scope :removed, { :conditions => "status = 5" }

  STATUSES = { 'undecided' => 0 ,
               'not interested' => 1,
               'interested' => 2,
               'accepted' => 3,
               'not accepted' => 4,
               'removed' => 5,
               0 => 'Undecided',
               1 => 'Not Interested',
               2 => 'Interested',
               3 => 'Accepted',
               4 => 'Not Accepted',
               5 => 'Removed',
               }

  def is_undecided?
    status == 0
  end

  def is_not_interested?
    status == 1
  end

  def is_interested?
    status == 2
  end

  def is_accepted?
    status == 3
  end

  def is_not_accepted?
    status == 4
  end

  def is_removed?
    status == 5
  end

end
