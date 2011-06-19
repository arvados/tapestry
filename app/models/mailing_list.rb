class MailingList < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  has_and_belongs_to_many :users, :join_table => :mailing_list_subscriptions

  validates_uniqueness_of :name
  validates_presence_of   :name

end
