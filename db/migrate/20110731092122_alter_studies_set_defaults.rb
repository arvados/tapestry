class AlterStudiesSetDefaults < ActiveRecord::Migration
  def self.up
    change_column_default(:studies, :requested, false)
    change_column_default(:studies, :approved, false)
    update "update studies set requested='f' where requested is null";
    update "update studies set approved='f' where approved is null";

  end

  def self.down
    change_column_default(:studies, :requested, nil)
    change_column_default(:studies, :approved, nil)
  end
end
