class Sample < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version
  acts_as_api

  belongs_to :study
  belongs_to :kit
  belongs_to :original_kit_design_sample, :class_name => "KitDesignSample"
  belongs_to :kit_design_sample

  belongs_to :participant, :class_name => "User"
  belongs_to :owner, :class_name => "User"

  has_many :sample_logs

  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :study_id
  validates_presence_of :kit_id

  scope :real, where('samples.is_destroyed is ?',nil)
  scope :destroyed, where('samples.is_destroyed is not ?',nil)
  scope :visible_to, lambda { |user|
    if user.is_admin?
      unscoped.scoped(:include => [:study, :participant, :owner])
    else
      real.scoped(:include => [:study, :participant, :owner],
                  :conditions => ['samples.owner_id=? or studies.creator_id=?',
                                  user.id, user.id])
    end
  }

  def crc_id_s
    "%08d" % crc_id
  end

  api_accessible :researcher do |t|
    t.add :id
    t.add :study
    t.add :participant, :template => :id
    t.add :owner, :template => :id
    t.add :kit, :template => :id
    t.add :crc_id_s, :as => :crc_id
  end

  api_accessible :privileged, :extend => :researcher do |t|
    t.add :url_code
  end

  def self.help_datatables_sort_by(sortkey, options={})
    sortkey = sortkey.to_s.gsub(/^sample\./, '')
    case sortkey
    when 'id', 'crc_id'
      "#{table_name}.#{sortkey}"
    when 'study.name'
      ['studies.name', { :study => {} }]
    when 'participant.hex'
      ['users.hex', { :participant => {} }]
    when 'kit.name'
      ['kits.name', { :kit => {} }]
    when 'url_code'
      (options[:for] and options[:for].is_admin?) ? 'samples.url_code' : 'sample.id'
    else
      'samples.crc_id'
    end
  end

  def self.help_datatables_search(options)
    s = "#{table_name}.id like :search or #{table_name}.crc_id like :search"
    if options[:for] and options[:for].is_admin?
      s << " or #{table_name}.url_code like :search"
    end
    s << " or users.hex like :search"
    s << " or kits.name like :search"
    [s, { :kit => {}, :participant => {} }]
  end
end
