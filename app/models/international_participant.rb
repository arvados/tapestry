class InternationalParticipant < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_presence_of       :country

  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false, :message => "address is already registered"
  validates_format_of       :email,    :with => /.+@.+\...+/, :message => " address is invalid"

end
