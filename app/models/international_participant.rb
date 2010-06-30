class InternationalParticipant < ActiveRecord::Base
  validates_length_of       :country,    :within => 3..100

  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /.+@.+\...+/, :message => " address is invalid"

end
