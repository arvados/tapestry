class Document < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id

  named_scope :kind, lambda { |keyword,version|
    { :conditions => { :keyword => keyword, :version => version }, :order => 'version DESC' }
  }

  named_scope :kind_any_version, lambda { |keyword|
    { :conditions => { :keyword => keyword }, :order => 'version DESC' }
  }

  named_scope :tos, { :conditions => "keyword = 'tos'", :order => 'version DESC' }
  named_scope :eligibility_survey, { :conditions => "keyword = 'eligibility_survey'", :order => 'version DESC'  }
  named_scope :consent, { :conditions => "keyword = 'consent'", :order => 'version DESC'  }
  named_scope :exam, { :conditions => "keyword = 'exam'", :order => 'version DESC'  }

end
