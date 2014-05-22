class ShippingAddress < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  # Setting :check_process to false forces an update to the geocoordinates on every save/update
  acts_as_gmappable :check_process => false

  def gmaps4rails_address
    @address = address_line_1
    @address += ", #{address_line_2}" unless address_line_2.nil? or address_line_2 == ''
    @address += ", #{address_line_3}" unless address_line_2.nil? or address_line_3 == ''
    @address += ", #{city}, #{state} #{zip}"
    @address
  end

  belongs_to :user

  validates_presence_of     :user_id
  validates_presence_of     :address_line_1
  validates_presence_of     :city
  validates_presence_of     :state
  validates_presence_of     :zip
  validates_presence_of     :phone

  attr_accessible :address_line_1, :address_line_2, :address_line_3,
                  :city, :state, :zip, :phone

  include SiteSpecific::Validations rescue {}

  def as_multiline_string
    @a = address_line_1
    @a << "\n" << address_line_2 if address_line_2 and address_line_2 != ''
    @a << "\n" << address_line_3 if address_line_3 and address_line_3 != ''
    @a << "\n" << city << ', ' << state << '  ' << zip
    @a
  end
end
