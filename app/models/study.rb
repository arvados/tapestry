class Study < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :researcher, :class_name => "User"
  belongs_to :irb_associate, :class_name => "User"

  has_many :kit_designs

  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_presence_of   :researcher_id

  validates_presence_of   :participant_description
  validates_presence_of   :researcher_description

end
