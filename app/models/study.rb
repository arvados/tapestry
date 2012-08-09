class Study < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version
  acts_as_api

  belongs_to :researcher, :class_name => "User"
  belongs_to :irb_associate, :class_name => "User"

  has_many :kit_designs
  has_many :kits
  # BEWARE: study.study_participants includes test users... I can't find a way to exclude them here. Use
  # study.study_participants.real (a scope on the study_participants model) instead. Ward, 2011-07-31
  has_many :study_participants, :dependent => :destroy
  has_many :users, :through => :study_participants, :conditions => ['users.is_test = ?', false]

  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :researcher_id

  validates_presence_of   :participant_description
  validates_presence_of   :researcher_description

  validates_presence_of :irb_associate, :message => ' is required if the study is approved', :if => :is_approved?

  scope :requested, where('requested = ?',true)
  scope :approved, where('approved = ?',true)
  scope :draft, where('requested = ? and approved = ?',false,false)

  scope :accessible, lambda { |user|
    if user.is_admin? then
      all
    elsif user.is_researcher? then
      where("researcher_id = ?",user.id)
    end
  }
  scope :visible_to, lambda { |current_user| accessible(current_user) }

  def is_approved?
    self.approved
  end

  def is_open?
    self.open
  end

  def status
    if self.approved then
      return 'approved'
    elsif self.requested then
      return 'requested'
    else
      return 'draft'
    end
  end

  api_accessible :public do |t|
    t.add :name
  end

  api_accessible :researcher, :extend => :public do |t|
  end

end
