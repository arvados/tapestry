class FamilyRelation < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :relative, :class_name => "User", :foreign_key => "relative_id"

  @@relations = {
    'parent' => 'child',
    'child' => 'parent',
    'sibling' => 'sibling',
    'grandparent' => 'grandchild',
    'grandchild' => 'grandparent'
  }
  
  def self.relations
    @@relations
  end
end
