class CreateProcedureDescriptions < ActiveRecord::Migration
  def self.up
    create_table :procedure_descriptions do |t|
      t.string :description, :null => false
    end
    add_index :procedure_descriptions, :description, :unique => true
    add_column :procedures, :procedure_description_id, :integer
    add_index :procedures, :procedure_description_id
    remove_column :procedures, :description
  end

  def self.down
    add_column :procedures, :description, :string
    remove_index :procedures, :column => :procedure_description_id
    remove_column :procedures, :procedure_description_id
    remove_index :procedure_descriptions, :column => :description
    drop_table :procedure_descriptions
  end
end
