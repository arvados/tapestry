class CreateAllergyDescriptions < ActiveRecord::Migration
  def self.up
    create_table :allergy_descriptions do |t|
      t.string :description, :null => false
    end
    add_index :allergy_descriptions, :description, :unique => true
    add_column :allergies, :allergy_description_id, :integer
    add_index :allergies, :allergy_description_id
    remove_column :allergies, :description
  end

  def self.down
    add_column :allergies, :description, :string
    remove_index :allergies, :column => :allergy_description_id
    remove_column :allergies, :allergy_description_id
    remove_index :allergy_descriptions, :column => :description
    drop_table :allergy_descriptions
  end
end
