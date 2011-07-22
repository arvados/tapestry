class ShippingAddress < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

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
