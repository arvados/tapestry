class MailingList < ActiveRecord::Base

  has_and_belongs_to_many :users, :join_table => :mailing_list_subscriptions

  validates_uniqueness_of :name

end
