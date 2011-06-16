class KitDesign < ActiveRecord::Base

  # See config/initializers/paperclip.rb for the definition of :study_id and :instructions_filename
  has_attached_file :instructions, :path => "/data/#{ROOT_URL}/studies/:study_id/:instructions_filename.:extension"

  belongs_to :study
  belongs_to :creator, :class_name => 'User'

  validates_presence_of    :name
  validates_uniqueness_of  :name
  validates_presence_of    :description
  validates_presence_of    :study_id
  validates_presence_of    :creator_id

  validates_attachment_presence   :instructions, :message => ': please select a file for upload.'
  validates_attachment_size :instructions, :less_than => 10485760, :message => ': maximum file size is 10 MB'

  DATA_TYPES = { 'PDF' => 'PDF' }.sort


end
