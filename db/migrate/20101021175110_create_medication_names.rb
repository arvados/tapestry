class CreateMedicationNames < ActiveRecord::Migration
  def self.up
    create_table :medication_names do |t|
      t.string :name, :null => false
    end
    add_index :medication_names, :name, :unique => true
    add_column :medications, :medication_name_id, :integer
    add_index :medications, :medication_name_id
    remove_column :medications, :name
  end

  def self.down
    add_column :medications, :name, :string
    remove_index :medications, :column => :medication_name_id
    remove_column :medications, :medication_name_id
    remove_index :medication_names, :column => :name
    drop_table :medication_names
  end
end
