class BulkMessageRecipient < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :bulk_message
  belongs_to :user

end
