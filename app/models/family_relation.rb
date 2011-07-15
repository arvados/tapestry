class FamilyRelation < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :relative, :class_name => "User", :foreign_key => "relative_id"

  @@relations = {
    'monozygotic/identical twin' => 'monozygotic/identical twin',
    'parent' => 'child',
    'child' => 'parent',
    'sibling' => 'sibling',
    'grandparent' => 'grandchild',
    'grandchild' => 'grandparent',
    'aunt/uncle' => 'nephew/niece',
    'nephew/niece' => 'aunt/uncle',
    'half sibling' => 'half sibling',
    'cousin or more distant' => 'cousin or more distant',
    'not genetically related (e.g. husband/wife)' => 'not genetically related (e.g. husband/wife)'
  }
  
  def self.relations
    @@relations
  end
end
