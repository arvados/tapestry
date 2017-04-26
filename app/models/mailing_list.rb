class MailingList < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  has_many :mailing_list_subscriptions, :dependent => :destroy
  has_many :users, :through => :mailing_list_subscriptions

  validates_uniqueness_of :name
  validates_presence_of   :name

end
