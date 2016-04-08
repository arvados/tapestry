class DatasetReport < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :user_file
  acts_as_paranoid_versioned :version_column => :lock_version

  validate :dataset_or_user_file

  def dataset_or_user_file
    if dataset_id.nil? == user_file_id.nil?
      errors.add(:dataset_id, 'can be nil iff user_file_id is not nil')
    end
  end
end
