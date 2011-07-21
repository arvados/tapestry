class Study < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :researcher, :class_name => "User"
  belongs_to :irb_associate, :class_name => "User"

  has_many :kit_designs

  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :researcher_id

  validates_presence_of   :participant_description
  validates_presence_of   :researcher_description

  validates_presence_of :irb_associate, :message => ' is required if the study is approved', :if => :is_approved?

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

end
