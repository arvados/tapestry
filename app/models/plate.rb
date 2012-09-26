class Plate < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :creator, :class_name => "User"
  belongs_to :plate_layout
  has_many :plate_samples
  has_many :samples, :through => :plate_samples
  belongs_to :derived_from_plate, :class_name => "Plate", :inverse_of => :derived_plates
  has_many :derived_plates, :class_name => "Plate", :foreign_key => :derived_from_plate_id

  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :plate_layout_id

  attr_protected :crc_id
  attr_protected :url_code

  before_validation(:on => :create) do
    self.crc_id = Kit.generate_verhoeff_number(self)
    self.url_code = Kit.generate_url_code(self)
  end

  def crc_id_s
    "%08d" % crc_id
  end

  def transfer_sample_to_position(sample, plate_layout_position, actor)
    ps = PlateSample.where('plate_id=? and plate_layout_position_id=?',
                           self.id, plate_layout_position.id).first
    if ps
      ps.sample = sample
      ps.is_unusable = false
      ps.save!
    else
      PlateSample.new(:plate => self,
                      :sample => sample,
                      :plate_layout_position => plate_layout_position).save!
    end
    SampleLog.new(:actor => actor,
                  :comment => "Sample transferred to plate #{self.crc_id_s} (id=#{self.id}) well #{plate_layout_position.name} (id=#{plate_layout_position.id})",
                  :sample_id => sample.id).save!
  end

  def dup(options)
    actor = options[:actor]
    ActiveRecord::Base.transaction do
      newplate = Plate.create(:creator => actor,
                              :plate_layout => self.plate_layout,
                              :description => self.description,
                              :derived_from_plate => self)
      self.plate_samples.each do |ps|
        if ps.sample and not ps.is_unusable
          derived_sample = ps.sample.dup(options) or
            raise "Failed to create derived sample from #{ps.sample.crc_id_s}"
        else
          derived_sample = nil
        end
        newps = PlateSample.create(ps.attributes)
        newps.sample = derived_sample
        newps.creator = actor
        newplate.plate_samples << newps
      end
      newplate.save!
      self.derived_plates << newplate
      newplate
    end
  end

  def original_plate
    x = self
    while x.derived_from_plate
      x = x.derived_from_plate
    end
    x
  end

  def <=>(other)
    x = self.original_plate.id <=> other.original_plate.id
    x = (self.derived_from_plate_id or 0) <=> (other.derived_from_plate_id or 0) if x == 0
    x = self.id <=> other.id if x == 0
    x
  end

  def is_accepting_samples?
    !derived_from_plate and derived_plates.empty?
  end
end
