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

  has_many :samples, :dependent => :destroy

  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :study_id
  validates_presence_of :kit_design_id

  scope :owned_by, lambda { |user_id| where('owner_id = ?', user_id) }
  scope :participant, lambda { |user_id| where('participant_id = ?', user_id) }

  scope :shipped, where('participant_id is ? and shipper_id is not ? and owner_id is ?',nil,nil,nil)
  scope :claimed, where('participant_id is not ? and owner_id=participant_id',nil)
  scope :returned, where('participant_id is not ? and owner_id is ?',nil,nil)
  scope :received, where('participant_id is not ? and owner_id is not ? and owner_id != participant_id',nil,nil)

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
 

  # Class methods, used both from controllers and observers. I had them in the
  # application controller, but then the observers can't use them...
  def self.generate_verhoeff_number(o)
    done = false
    number = ''
    while not done
      number = ("%x%x%x%x%x%x%x%x" % [ rand(10), rand(10), rand(10), rand(10), rand(10), rand(10), rand(10), rand(10) ]).to_i
      done = true if Verhoeff.checks_out? number and o.class.where('crc_id = ?',number).empty?
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

end
