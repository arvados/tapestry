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

  before_validation :normalize_third_party_fields
  validates_format_of :participation_url, {
    :with => %r{^https?://[^/\s]{4,}(/\S*)?$},
    :message => 'must be a valid http:// or https:// web address',
    :allow_nil => true
  }

  scope :requested, where('requested = ?',true)
  scope :approved, where('approved = ?',true)
  scope :draft, where('requested = ? and approved = ?',false,false)
  scope :not_third_party, where('participation_url is ?', nil)
  scope :third_party, where('participation_url is not ?', nil)
  scope :open, where('open = ? and approved = ?',true,true)
  scope :not_open, where('open = ?',false)

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

  def normalize_third_party_fields
    self.participation_url = nil if !@is_third_party
  end

  def is_third_party
    !self.participation_url.nil?
  end

  def is_third_party=(bool)
    @is_third_party = (bool && bool.to_s != '0')
  end

  def personalized_participation_url(user)
    s = participation_url
    s << (s.match(/\?/) ? '&' : '?')
    s << 'study_id=' << id.to_s
    s << '&participant_id='
    s << user.app_token("Study##{self.id}")
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

  def study_type
    return 'study or collection event' if !id
    is_third_party ? 'activity' : 'collection event'
  end

  api_accessible :public do |t|
    t.add :name
  end

  api_accessible :researcher, :extend => :public do |t|
  end

end
