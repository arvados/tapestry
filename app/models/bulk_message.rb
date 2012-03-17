class BulkMessage < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  attr_accessor :recipients_file

  validates_length_of :subject, :minimum => 5, :maximum => 70
  validates_length_of :body, :minimum => 20

  # Check uploaded file, but it is only compulsory on create. On update,
  # if no file is provided, we just don't modify the existing file.
  validate :check_file, :on => :create

  def check_file
    if self.recipients_file.nil? then
      errors.add :recipients_file, 'Please provide a csv file with one column with hex IDs for recipients'
    end
  end

  has_many :recipients, :through => :bulk_message_recipients, :source => :user
  has_many :bulk_message_recipients

end
