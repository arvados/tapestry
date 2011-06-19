class Document < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user
  validates_presence_of :user_id

  scope :kind, lambda { |keyword,version|
    { :conditions => { :keyword => keyword, :version => version }, :order => 'version DESC' }
  }

  scope :kind_any_version, lambda { |keyword|
    { :conditions => { :keyword => keyword }, :order => 'version DESC' }
  }

  scope :tos, { :conditions => "keyword = 'tos'", :order => 'version DESC' }
  scope :eligibility_survey, { :conditions => "keyword = 'eligibility_survey'", :order => 'version DESC'  }
  scope :consent, { :conditions => "keyword = 'consent'", :order => 'version DESC'  }
  scope :exam, { :conditions => "keyword = 'exam'", :order => 'version DESC'  }

end
