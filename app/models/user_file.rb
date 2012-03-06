class UserFile < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version


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

  DATA_TYPES = { 'genetic data - 23andMe' => '23andMe', 
                 'genetic data - Pathway Genomics' => 'Pathway genomics', 
                 'genetic data - Counsyl' => 'Counsyl', 
                 'genetic data - DeCode' => 'DeCode', 
                 'genetic data - Knome' => 'Knome', 
                 'genetic data - Illumina' => 'Illumina', 
                 'genetic data - Navigenics' => 'Navigenics', 
                 'genetic data - Family Tree DNA' => 'Family Tree DNA',
                 'health records - PDF or text' => 'health records - PDF or text',
                 'health records - CCR XML' => 'health records - CCR XML',
                 'biometric data - CSV or similar' => 'biometric data - CSV or similar',
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
end
