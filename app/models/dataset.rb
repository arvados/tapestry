class Dataset < ActiveRecord::Base
  acts_as_versioned
  stampable

  serialize :processing_status, Hash

  belongs_to :participant, :class_name => 'User'
  belongs_to :sample

  validates :name, :uniqueness => { :scope => 'participant_id' }
  validates :participant, :presence => true

  validates :human_id, :presence => true

  validate :must_have_valid_human_id

  scope :released_to_participant, where('released_to_participant')
  scope :published, where('published_at is not null')
  scope :unpublished, where('published_at is null')

  attr_accessor :submit_to_get_e

  def must_have_valid_human_id
    if User.where('hex = ?',human_id).first.nil? then
      errors.add :base, "There is no participant with this hex id"
    end
  end

  before_validation :set_participant_id

  # implement "genetic data" interface
  def date
    published_at
  end
  def data_type
    "Whole Genome or Exome"
  end
  def download_url
    if !super and self.location and self.location.match(/evidence\.personalgenomes\.org\/hu[0-9A-F]+$/)
      "http://evidence.personalgenomes.org/genome_download.php?download_genome_id=#{sha1}&download_nickname=#{CGI::escape(name)}"
    else
      super
    end
  end

  def submit_to_get_evidence!(make_public = 0)
    submit_params = {
      'api_key' => GET_EVIDENCE_API_KEY,
      'api_secret' => GET_EVIDENCE_API_SECRET,
      'dataset_locator' => self.locator,
      'dataset_name' => self.name,
      'dataset_is_public' => make_public,
      'human_id' => self.human_id
    }.collect {
      |k,v| URI.encode(k, /\W/) + '=' + URI.encode(v.to_s, /\W/)
    }.join('&')
    json_object = JSON.parse(open("#{GET_EVIDENCE_BASE_URL}/submit?#{submit_params}").read)
    self.location = json_object['result_url']
    self.download_url = json_object['download_url']
    self.status_url = json_object['status_url']
    self.processing_stopped = false
    self.save!
    logger.debug self.inspect
    self.update_processing_status! rescue nil
  end

  def update_processing_status!
    self.processing_status = JSON.parse(open(self.status_url).read,
                                        :symbolize_names => true)[:status]
    self.processing_status[:updated_at] = Time.now
    if ['finished','failed'].index(self.processing_status[:status])
      self.processing_stopped = true
    end
    self.save
  end

protected
  def set_participant_id
    @p = User.where('hex = ?',self.human_id).first

    # We have a validator that handles the case where @p is nil
    if not @p.nil? then
      self.participant_id = @p.id
    end
  end

end
