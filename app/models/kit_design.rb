class KitDesign < ActiveRecord::Base
  acts_as_api
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  # See config/initializers/paperclip.rb for the definition of :study_id and :instructions_filename
  has_attached_file :instructions, :path => "/data/#{ROOT_URL}/studies/:study_id/:instructions_filename.:extension"

  belongs_to :study
  belongs_to :owner, :class_name => 'User'

  has_many :samples, :class_name => 'KitDesignSample', :order => 'sort_order', :inverse_of => :kit_design

  accepts_nested_attributes_for :samples, :allow_destroy => true

  validates_presence_of    :name
  validates_uniqueness_of  :name
  validates_presence_of    :description
  validates_presence_of    :study_id
  validates_presence_of    :owner_id

  validates_attachment_presence   :instructions, :message => ': please select a file for upload.'
  validates_attachment_size :instructions, :less_than => 10485760, :message => ': maximum file size is 10 MB'

  DATA_TYPES = { 'PDF' => 'PDF' }.sort

  def editable?
    not self.frozen
  end

  api_accessible :id do |t|
    t.add :id
    t.add :name
  end
end
