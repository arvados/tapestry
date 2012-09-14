class Dataset < ActiveRecord::Base
  acts_as_api
  acts_as_versioned
  stampable

  serialize :processing_status, Hash
  serialize :report_metadata, Hash
  include SubmitToGetEvidence

  belongs_to :participant, :class_name => 'User'
  belongs_to :sample

  validates :name, :uniqueness => { :scope => 'participant_id' }
  validates :participant, :presence => true

  validates :human_id, :presence => true

  validate :must_have_valid_human_id

  scope :released_to_participant, where('released_to_participant')
  scope :not_released_to_participant, where('released_to_participant is false')
  scope :seen_by_participant, where('seen_by_participant_at is not null')
  scope :published, where('published_at is not null')
  scope :unpublished, where('published_at is null')

  attr_accessor :submit_to_get_e

  def must_have_valid_human_id
    if User.where('hex = ?',human_id).first.nil? then
      errors.add :base, "There is no participant with this hex id"
    end
  end

  before_validation :set_participant_id
  before_save :set_data_size

  # implement "genetic data" interface
  def date
    published_at
  end
  def data_type
    "Complete Genomics"
  end
  def download_url
    if !super and self.location and self.location.match(/evidence\.personalgenomes\.org\/hu[0-9A-F]+$/)
      "http://evidence.personalgenomes.org/genome_download.php?download_genome_id=#{sha1}&download_nickname=#{CGI::escape(name)}"
    else
      super
    end
  end

  def report_url
    self.location
  end

  def is_suitable_for_get_evidence?
    locator and !locator.empty?
  end

  api_accessible :public do |t|
    t.add :id
    t.add :name, :if => :published_at
    t.add :participant, :template => :id, :if => :published_at
    t.add :data_size, :if => :published_at
    t.add :report_metadata, :if => :published_at
  end

  api_accessible :researcher, :extend => :public do |t|
  end

  api_accessible :privileged, :extend => :researcher do |t|
    t.add :name
    t.add :participant, :template => :id
    t.add :data_size
  end

protected
  def set_participant_id
    @p = User.where('hex = ?',self.human_id).first

    # We have a validator that handles the case where @p is nil
    if not @p.nil? then
      self.participant_id = @p.id
    end
  end

  def set_data_size
    self.data_size = nil
    if locator and locator.match /^[\da-f]{32}/
      manifest = `whget '#{locator.gsub("'","'\\''")}'`
      if (m = manifest.match /^[^\n]+ 0:(\d+):\S+\n?$/)
        self.data_size = m[1].to_i
      end
    end
  end

  # interface required by SubmitToGetEvidence
  def report_url=(x)
    self.location = x           # that's just what we call it
  end

end
