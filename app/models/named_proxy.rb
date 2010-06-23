class NamedProxy < ActiveRecord::Base
  belongs_to :user

  validates_length_of       :name,    :within => 3..100

  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :email,    :case_sensitive => false, :scope => :user_id
  validates_format_of       :email,    :with => /.+@.+\..+/, :message => " address is invalid"

  


end
