class CreateKitDesigns < ActiveRecord::Migration
  def self.up
    create_table :kit_designs do |t|
      t.string :name
      t.text :description
      t.belongs_to :creator, :class_name => User
      t.belongs_to :study
      t.boolean :frozen
      t.text :errata

      t.string :instructions_file_name
      t.string :instructions_content_type
      t.integer :instructions_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :kit_designs
  end
end
