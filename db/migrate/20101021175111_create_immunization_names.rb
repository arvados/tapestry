class CreateImmunizationNames < ActiveRecord::Migration
  def self.up
    create_table :immunization_names do |t|
      t.string :name, :null => false
    end
    add_index :immunization_names, :name, :unique => true
    add_column :immunizations, :immunization_name_id, :integer
    add_index :immunizations, :immunization_name_id
    remove_column :immunizations, :name
  end

  def self.down
    add_column :immunizations, :name, :string
    remove_index :immunizations, :column => :immunization_name_id
    remove_column :immunizations, :immunization_name_id
    remove_index :immunization_names, :column => :name
    drop_table :immunization_names
  end
end
