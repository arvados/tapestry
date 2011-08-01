class AlterKitDesignsSetDefaults < ActiveRecord::Migration
  def self.up
    change_column_default(:kit_designs, :frozen, false)
    update "update kit_designs set frozen='f' where frozen is null";

  end

  def self.down
    change_column_default(:kit_designs, :frozen, nil)
  end
end
