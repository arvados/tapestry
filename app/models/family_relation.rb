class FamilyRelation < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :relative, :class_name => "User", :foreign_key => "relative_id"
end
