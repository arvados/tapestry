class MailingListSubscription < ActiveRecord::Base
  stampable

  belongs_to :mailing_list
  belongs_to :user
end
