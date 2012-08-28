class Report < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  def short_status
    if status.length > 20 then
      return "<p title=\"#{h(status)}\">#{h(status[0..19])}...</p>"
    else
      return status
    end
  end
end
