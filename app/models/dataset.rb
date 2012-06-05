class Dataset < ActiveRecord::Base
  acts_as_versioned
  stampable

  belongs_to :participant, :class_name => 'User'

  validates :name, :uniqueness => { :scope => 'participant_id' }
  validates :participant, :presence => true

  validates :human_id, :presence => true

  validate :must_have_valid_human_id

  attr_accessor :submit_to_get_e

  def must_have_valid_human_id
    if User.where('hex = ?',human_id).first.nil? then
      errors.add :base, "There is no participant with this hex id"
    end
  end

  before_validation :set_participant_id

  # implement "genetic data" interface
  def date
    "N/A"
  end
  def data_type
    "Whole Genome or Exome"
  end
  def download_url
    "http://evidence.personalgenomes.org/genome_download.php?download_genome_id=#{sha1}&download_nickname=#{CGI::escape(name)}"
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
