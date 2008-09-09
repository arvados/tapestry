class Exam < ActiveRecord::Base
  has_many :versions, :class_name => 'ExamVersion'
  has_one :published_version, :class_name => 'ExamVersion'
  belongs_to :content_area

  def version_for(user)
    versions.find :first,
      :conditions => [ 'created_at < ? and published = ?', user.created_at, true ],
      :order => 'created_at DESC'
  end
end
