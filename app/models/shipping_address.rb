class ShippingAddress < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  # Setting :check_process to false forces an update to the geocoordinates on every save/update
  acts_as_gmappable :check_process => false

  def gmaps4rails_marker_picture
    # TODO FIXME: this function is currently hardcoded for Study.find(1). That's not good.
    # yellow: shipped
    # green: claimed
    # blue: returned
    # red: something went wrong
    # Kit is created / possibly shipped. We currently do not keep track of which addresses kits are shipped to so
    # we can not distinguish between these 2 states.
    @picture = '/images/yellow.png'
    # Claimed by participant
    @picture = '/images/green.png' if Study.find(1).kits.claimed.collect { |x| x.participant.shipping_address.id }.include?(id)
    # Returned to researcher
    @picture = '/images/blue.png' if Study.find(1).kits.returned.collect { |x| x.participant.shipping_address.id }.include?(id)
    # Received by researcher
    @picture = '/images/brown.png' if Study.find(1).kits.received.collect { |x| x.participant.shipping_address.id }.include?(id)
    {
      "picture" => @picture,    # string, mandatory
       "width" =>  23,          # string, mandatory
       "height" => 34,          # string, mandatory
     }
  end

  def gmaps4rails_title
    self.user.hex
  end

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


end
