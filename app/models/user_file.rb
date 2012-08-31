class UserFile < ActiveRecord::Base
  acts_as_api
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :processing_status, Hash
  serialize :report_metadata, Hash
  include SubmitToGetEvidence

  # See config/initializers/paperclip.rb for the definition of :user_id and :filename
  has_attached_file :dataset, :path => "/data/#{ROOT_URL}/genetic_data/:user_id/:id/:style/:filename.:extension"

  belongs_to :user

  attr_accessible :user, :user_id, :name, :date, :description, :data_type, :dataset, :upload_tos_consent

  attr_accessor :other_data_type

  validates_presence_of    :user_id
  validates_presence_of    :name
  validates_uniqueness_of  :name

  validates_presence_of    :data_type, :message => ': please select a data type.'
  validates_attachment_presence   :dataset, :message => ': please select a file for upload.'
  validates_attachment_size :dataset, :less_than => 31457280, :message => ': maximum file size is 30 MiB'

  validates_acceptance_of :upload_tos_consent, :accept => true

  validates_presence_of :other_data_type, :if => 'data_type == "other"'

  DATA_TYPES = { 'genetic data - 23andMe (e.g., exome or genotyping data)' => '23andMe', 
                 'genetic data - Complete Genomics' => 'Complete Genomics', 
                 'genetic data - Pathway Genomics' => 'Pathway genomics', 
                 'genetic data - Counsyl' => 'Counsyl', 
                 'genetic data - DeCode' => 'DeCode', 
                 'genetic data - Knome' => 'Knome', 
                 'genetic data - Illumina (e.g., EveryGenome data)' => 'Illumina', 
                 'genetic data - Navigenics' => 'Navigenics', 
                 'genetic data - Family Tree DNA' => 'Family Tree DNA',
                 'health records - PDF or text' => 'health records - PDF or text',
                 'health records - CCR XML' => 'health records - CCR XML',
                 'biometric data - CSV or similar' => 'biometric data - CSV or similar',
                 'image - PNG or JPEG or similar' => 'image',
                 'other (please specify)' => 'other'
               }.sort

  def <=> other
    if (date.nil? && other.date.nil?) then
      return name <=> other.name
    elsif (date.nil?)
      return 1
    elsif (other.date.nil?)
      return -1
    else
      return date <=> other.date
    end
  end

  def location
    # "view" url, if any
    nil
  end

  def human_id
    # used by SubmitToGetEvidence
    self.user.hex
  end

  def participant
    # same interface as Dataset
    user
  end

  def data_size
    dataset.size if dataset and dataset.size
  end

  def is_suitable_for_get_evidence?
    (dataset_file_name.match(/\.vcf/) or
     (dataset_file_name.match(/\.(txt|zip)$/i) and data_type == '23andMe'))
  end

  def store_in_warehouse
    Open3.popen3('whput',
                 '--in-manifest',
                 "--name=/tapestry/#{ROOT_URL}/#{self.class}/#{self.id}",
                 "--use-filename=#{self.dataset_file_name}",
                 self.dataset.path) do |std_in, std_out, std_err, wait_thr|
      new_locator = std_out.gets
      if wait_thr.respond_to? :value
        # ruby 1.9.3 actual exit status
        exitvalue = wait_thr.value
      else
        # ruby 1.8.7 guess exit status based on output of whput
        exitvalue = (new_locator && new_locator.match(/^[\da-f]{32}\b/) ? 0 : -1)
      end
      if new_locator and !new_locator.empty? and exitvalue == 0
        self.locator = new_locator.strip
        self.save
        return true
      else
        logger.error "whput #{self.dataset.path} exited #{exitvalue}: #{std_err.gets}"
        puts "whput #{self.dataset.path} exited #{exitvalue}: #{std_err.gets}"
      end
    end
    false
  end

  api_accessible :public do |t|
    t.add :id
    t.add :name
    t.add :participant, :template => :id
    t.add :data_size
    t.add :report_metadata
  end

  api_accessible :researcher, :extend => :public do |t|
  end

  api_accessible :privileged, :extend => :researcher do |t|
  end
end
