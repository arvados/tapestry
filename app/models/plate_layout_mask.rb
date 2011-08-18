class PlateLayoutMask < ActiveRecord::Base
  validates_uniqueness_of :ytarget, :scope => [:xmodulus, :ymodulus, :xtarget]

  def exposed?(pos)
    # pos.xpos, pos.ypos are 1-based coordinates but I use 0-based coordinates
    ((pos.xpos-1) % self.xmodulus == self.xtarget and
     (pos.ypos-1) % self.ymodulus == self.ytarget)
  end

  def <=>(x)
    return self.ymodulus <=> x.ymodulus unless self.ymodulus == x.ymodulus
    return self.xmodulus <=> x.xmodulus unless self.xmodulus == x.xmodulus
    return self.ytarget <=> x.ytarget unless self.ytarget == x.ytarget
    self.xtarget <=> x.xtarget
  end
end
