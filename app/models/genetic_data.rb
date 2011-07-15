class GeneticData < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version


  # See config/initializers/paperclip.rb for the definition of :user_id and :filename
  has_attached_file :dataset, :path => "/data/#{ROOT_URL}/genetic_data/:user_id/:id/:style/:filename.:extension"

  belongs_to :user

  attr_accessible :user, :user_id, :name, :date, :description, :data_type, :dataset

  validates_presence_of    :user_id
  validates_presence_of    :name
  validates_uniqueness_of  :name

  validates_presence_of    :data_type, :message => ': please select a data type.'
  validates_attachment_presence   :dataset, :message => ': please select a file for upload.'
  validates_attachment_size :dataset, :less_than => 31457280, :message => ': maximum file size is 30 MiB'

  DATA_TYPES = { '23andMe' => '23andMe', 
                  'Pathway Genomics' => 'Pathway genomics', 
                  'Counsyl' => 'Counsyl', 
                  'DeCode' => 'DeCode', 
                  'Knome' => 'Knome', 
                  'Illumina' => 'Illumina', 
                  'Navigenics' => 'Navigenics', 
                  'Family Tree DNA' => 'Family Tree DNA' }.sort

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

end
