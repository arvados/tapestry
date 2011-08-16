class PlateLayoutPosition < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :plate_layout
  validates_presence_of :xpos
  validates_presence_of :ypos
  validates_uniqueness_of :xpos, :scope => [:ypos, :plate_layout_id]
  validates_uniqueness_of :name, :scope => :plate_layout_id

  def <=>(x)
    return self.ypos <=> x.ypos unless self.ypos == x.ypos
    self.xpos <=> x.xpos
  end
end
