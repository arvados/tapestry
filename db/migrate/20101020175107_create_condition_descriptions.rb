class CreateConditionDescriptions < ActiveRecord::Migration
  def self.up
    create_table :condition_descriptions do |t|
      t.string :description, :null => false
    end
    add_index :condition_descriptions, :description, :unique => true
    add_column :conditions, :condition_description_id, :integer
    add_index :conditions, :condition_description_id
    remove_column :conditions, :description
  end

  def self.down
    add_column :conditions, :description, :string
    remove_index :conditions, :column => :condition_description_id
    remove_column :conditions, :condition_description_id
    remove_index :condition_descriptions, :column => :description
    drop_table :condition_descriptions
  end
end
