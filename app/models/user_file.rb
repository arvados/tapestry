class UserFile < ActiveRecord::Base
  acts_as_api
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :processing_status, Hash
  serialize :report_metadata, Hash
  include SubmitToGetEvidence
  include Longupload::Target
  include Longupload::StoresInWarehouse
  include FileDataInWarehouse

  scope :find_all_by_longupload_info, lambda { |info|
    where('user_id = ? and (id = ? or (longupload_fingerprint = ? and longupload_file_name = ?))',
          info[:user].id,
          info[:longupload_id].to_i,
          info[:longupload_fingerprint],
          info[:longupload_file_name])
  }
  scope :downloadable, where('dataset_file_size is not ? or locator is not ?', nil, nil)
  scope :visible_to, lambda { |user|
    if user and user.is_admin?
      downloadable
    else
      downloadable.scoped(:include => [:user],
                          :conditions => ['users.enrolled is not ? and users.suspended_at is ?', nil, nil])
    end
  }

  # See config/initializers/paperclip.rb for the definition of :user_id and :filename
  has_attached_file :dataset, :path => "/data/#{ROOT_URL}/genetic_data/:user_id/:id/:style/:filename.:extension"

  belongs_to :user

  attr_accessible :user, :user_id, :name, :date, :description, :data_type, :dataset, :upload_tos_consent, :longupload_size, :longupload_fingerprint, :longupload_file_name, :using_plain_upload, :index_in_manifest, :path_in_manifest, :locator, :other_data_type

  attr_accessor :other_data_type
  attr_accessor :using_plain_upload

  validates_presence_of    :user_id
  validates_presence_of    :name

  validates_presence_of :dataset, :message => ': please select a file to upload.', :if => :using_plain_upload
  validates_attachment_size :dataset, :less_than => 31457280, :message => ': maximum file size is 30 MiB.', :if => :using_plain_upload
  validates_presence_of    :data_type, :message => ': please select a data type.'
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
                 'microbiome data' => 'Microbiome',
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
    if dataset and dataset.size
      dataset.size
    elsif dataset_file_size
      dataset_file_size
    elsif longupload_size
      longupload_size
    end
  end

  def initialize(*x)
    super(*x)
    if x.last.is_a? Hash
      self.dataset_file_size ||= x.last[:file_size]
      self.dataset_file_name ||= x.last[:file_name]
      self.name ||= x.last[:file_name]
    end
  end

  def is_plain_upload?
    dataset_file_size and !locator and !longupload_size
  end

  def is_incomplete?
    !dataset_file_size and !locator
  end

  def is_suitable_for_get_evidence?
    index_in_manifest.nil? and
      dataset_file_name and
      (dataset_file_name.match(/\.vcf/i) or
       dataset_file_name.match(/\.gff(\.bz2|\.gz)?$/i) or
       dataset_file_name.match(/^masterVar.*ASM\.tsv(\.bz2|\.gz)?$/i) or
       (dataset_file_name.match(/\.(txt|zip)$/i) and data_type == '23andMe'))
  end

  def store_in_warehouse
    return true if locator and !dataset.path # it's already (only) in warehouse
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

  def after_longupload_file
    super
    self.dataset_file_size = longupload_size
    self.dataset_file_name = longupload_file_name
    self.dataset_updated_at = Time.now
    self.dataset_content_type = 'application/octet-stream' # fixme - longupload client doesn't provide this info
    save!
  end

  # Longupload::StoresInWarehouse#after_longupload_file uses this
  def warehouse_manifest_locator=(x)
    self.locator = x
  end

  # get an IO object that will supply file data from "read" method
  def data_stream
    if self.is_incomplete?
      nil
    elsif self.locator and !File.exists?(self.dataset.path)
      IO.popen("whget -r '#{self.locator}/'", 'rb')
    else
      File.new(self.dataset.path, 'rb')
    end
  end

  # to match Dataset interface
  def published_at
    created_at
  end

  ##
  # return an ArvadosJob callback that adds UserFile records for
  # +opts[:user_id]+ for files that were downloaded in a batch
  # provided by study +opts[:study_id]+.
  def self.create_from_download_job_callback opts
    "proc { |job| UserFile.create_from_download_job({:job => job, :user_id => #{opts[:user_id]+0}, :study_id => #{opts[:study_id]+0}) }"
  end

  def self.create_from_download_job opts
    study = Study.find opts[:study_id]
    arv = Arvados.new(:apiVersion => 'v1')
    p_i = arv.pipeline_instance.get opts[:job].uuid
    pdh = p_i[:components][:download][:job][:output]
    create!(:user_id => opts[:user_id],
            :date => Time.now,
            :description => "Provided by #{study.name}",
            :locator => pdh,
            :path_in_manifest => "FIXME",
            :index_in_manifest => 0)
  end

  api_accessible :public do |t|
    t.add :id
    t.add :name
    t.add :participant, :template => :id
    t.add :data_size
    t.add :report_metadata
    t.add :locator
  end

  api_accessible :researcher, :extend => :public do |t|
  end

  api_accessible :privileged, :extend => :researcher do |t|
  end

  api_accessible :owner, :extend => :public do |t|
  end
end
