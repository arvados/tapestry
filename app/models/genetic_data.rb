class GeneticData < ActiveRecord::Base

  # See config/initializers/paperclip.rb for the definition of :user_id
  has_attached_file :dataset, :path => "/data/#{ROOT_URL}/genetic_data/:user_id/:id/:style/:basename.:extension"

  belongs_to :user

  attr_accessible :user, :user_id, :name, :date, :description, :data_type, :dataset

  validates_presence_of    :user_id
  validates_presence_of    :name
  validates_uniqueness_of  :name

  validates_presence_of    :data_type, :message => ': please select a data type.'
  validates_attachment_presence   :dataset, :message => ': please select a file for upload.'
  validates_attachment_size :dataset, :less_than => 10485760, :message => ': maximum file size is 10 MB'

  DATA_TYPES = { '23andMe' => '23andMe', 
                  'Good Start Genetics' => 'Good Start Genetics', 
                  'Pathway Genomics' => 'Pathway genomics', 
                  'Counsyl' => 'Counsyl', 
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
