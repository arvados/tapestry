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

  STATUSES = {
    'created' => [0, 'Kit created'],
    'sent' => [1, 'Kit shipped to participant'],
    'claimed' => [2, 'Kit claimed by participant'],
    'returned' => [3, 'Kit returned by participant'],
    'received' => [4, 'Kit received by researcher'],
    'lost' => [5, 'Kit lost'],
    'received-unclaimed' => [6, 'Kit received unclaimed'],
    'unknown' => [7, 'Unknown']
  }

  def short_status
    if self.lost_at then
      'lost'
    elsif self.participant.nil? and self.shipper.nil? then
      'created'
    elsif self.participant and self.owner.nil? and not self.last_received.nil? then
      'returned'
    elsif self.shipper and self.owner.nil? then
      'sent'
    elsif self.participant and self.owner == self.participant then
      'claimed'
    elsif self.participant and not self.owner.nil? and self.owner != self.participant then
      'received'
    elsif self.participant.nil? and not self.last_received.nil?
      'received-unclaimed'
    else
      'unknown'
    end
  end

  def numeric_status
    STATUSES[short_status][0]
  end

  def status
    STATUSES[short_status][1]
  end

  def send_to_participant!(current_user)
    self.lost_at = nil          # If I was lost before, evidently I am not now
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

  def status_changed_at
    [created_at, last_mailed, last_received, lost_at].compact.max
  end

  def age
    Time.now - status_changed_at
  end

  api_accessible :public do |t|
    t.add :id
    t.add :name
    t.add :age
    t.add :status_changed_at
    t.add :study, :template => :id
    t.add :participant, :template => :id
    t.add :owner, :template => :id
    t.add :crc_id_s, :as => :crc_id
    t.add :last_mailed
    t.add :last_received
    t.add :originator, :template => :id
    t.add :shipper, :template => :id
    t.add :kit_design, :template => :id
    t.add :status
    t.add :short_status
    t.add :numeric_status
  end

  api_accessible :researcher, :extend => :public do |t|
  end

  api_accessible :privileged, :extend => :researcher do |t|
  end

  def self.include_for_api(api_template)
    [:study, :participant, :owner, :shipper, :originator, :kit_design]
  end

  def self.csv_attribute_list
    ['name',
     ['crc_id_s', 'number'],
     ['(age/86400).floor', 'age'],
     ['short_status', 'status'],
     ['numeric_status', 'status#'],
     'status_changed_at',
     'kit_logs.last.updated_at',
     'kit_logs.last.actor.public_name',
     'kit_logs.last.comment',
     'last_mailed',
     'last_received',
     ['originator.public_name', 'originator'],
     ['shipper.public_name', 'shipper'],
     ['participant.public_name', 'participant'],
     ['owner.public_name', 'owner'],
     'kit_design.name',
     'study.name' ]
  end

  def as_csv_row
    self.class.csv_attribute_list.collect do |a|
      eval(a.class == Array ? a[0] : a) rescue nil
    end
  end

  def self.as_csv_header_row
    csv_attribute_list.collect do |a|
      (a.class == Array ? a[1] : a).
        sub('.public_name', '').
        gsub(/[\._]/, ' ')
    end
  end

  def self.status_counts(kits)
    kits.inject({}) { |h,k|
      h[k.short_status] ||= 0
      h[k.short_status] += 1
      h
    }.collect { |status,n|
      [status, n]
    }.sort_by { |status,n|
      STATUSES[status][0]
    }
  end
end
