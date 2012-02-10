class Report < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  def short_status
    if status =~ /^Failed:/ then
      return 'Failed'
    else
      return status
    end
  end
end
