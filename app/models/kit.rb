class Kit < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version
  acts_as_api

  belongs_to :study
  belongs_to :kit_design
  belongs_to :participant, :class_name => "User"
  belongs_to :owner, :class_name => "User"
  belongs_to :originator, :class_name => "User"
  belongs_to :shipper, :class_name => "User"

  has_many :kit_logs, :dependent => :destroy
  has_many :samples, :dependent => :destroy

  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :study_id
  validates_presence_of :kit_design_id

  scope :owned_by, lambda { |user_id| where('owner_id = ?', user_id) }
  scope :study, lambda { |study_id| where('study_id = ?', study_id) }
  scope :participant, lambda { |user_id| where('participant_id = ?', user_id) }

  scope :not_yet_shipped, where('participant_id is ? and shipper_id is ? and owner_id is not ?',nil,nil,nil)
  scope :shipped, where('participant_id is ? and shipper_id is not ? and owner_id is ?',nil,nil,nil)
  scope :claimed, where('participant_id is not ? and owner_id=participant_id',nil)
  scope :returned, where('participant_id is not ? and owner_id is ?',nil,nil)
  scope :received, where('participant_id is not ? and owner_id is not ? and owner_id != participant_id',nil,nil)

  scope :assigned_to_participant, where('participant_id is not ?',nil)

  scope :visible_to, lambda { |current_user|
    if current_user and current_user.is_admin?
      unscoped
    elsif current_user and current_user.is_researcher?
      joins(:study).merge(Study.visible_to(current_user))
    elsif current_user
      where('participant_id = ?', current_user.id)
    else
      where('1=0')
    end
  }

  api_accessible :id do |t|
    t.add :id
    t.add :name
    t.add :crc_id_s, :as => :crc_id
  end

  def crc_id_s
    "%08d" % crc_id
  end

  def status
    if self.participant.nil? and self.shipper.nil? then
      'Kit created'
    elsif self.participant and self.owner.nil? and not self.last_received.nil? then
      'Participant returned kit to researcher'
    elsif self.shipper and self.owner.nil? then
      'Kit shipped to participant'
    elsif self.participant and self.owner == self.participant then
      'Participant has kit'
    elsif self.participant and not self.owner.nil? and self.owner != self.participant then
      'Kit has been received by researcher'
    end
  end

  def send_to_participant!(current_user)
    self.last_mailed = Time.now()
    self.shipper_id = current_user.id
    # Nobody 'owns' the kit at the moment
    self.owner = nil
    self.save

    self.samples.each do |s|
      s.last_mailed = Time.now()
      s.owner = nil
      s.save
      SampleLog.new(:actor => current_user, :comment => 'Sample sent', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor => current_user, :comment => 'Kit sent', :kit_id => self.id).save
  end

  # Class methods, used both from controllers and observers. I had them in the
  # application controller, but then the observers can't use them...
  def self.generate_verhoeff_number(o)
    done = false
    number = ''
    while not done
      number = ("%x%x%x%x%x%x%x%x" % [ rand(10), rand(10), rand(10), rand(10), rand(10), rand(10), rand(10), rand(10) ]).to_i
      done = true if Verhoeff.valid? number and o.class.where('crc_id = ?',number).empty?
    end
    number
  end

  def self.generate_url_code(o)
    done = false
    code = ''
    alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
    while not done
      code = (0...6).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
      done = true if o.class.where('url_code = ?',code).empty?
    end
    code
  end

  def self.normalize_name(s)
    s.downcase if s
  end

  def normalized_name
    self.class.normalize_name(name)
  end

end
