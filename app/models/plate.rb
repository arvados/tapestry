class Plate < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :creator, :class_name => "User"
  belongs_to :plate_layout
  has_many :plate_samples
  has_many :samples, :through => :plate_samples

  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :plate_layout_id

  attr_protected :crc_id
  attr_protected :url_code

  before_validation(:on => :create) do
    self.crc_id = Kit.generate_verhoeff_number(self)
    self.url_code = Kit.generate_url_code(self)
  end

  def next_position
    return PlateLayoutPosition.find_by_xpos_and_ypos(3, 3)
  end
end
