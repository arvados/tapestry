class CreateGeneticData < ActiveRecord::Migration
  def self.up
    create_table :genetic_data do |t|
      t.column :user_id, :int
      t.string :name, :null => false
      t.string :data_type, :null => false
      t.date :date
      t.text :description, :null => false

      t.string :dataset_file_name
      t.string :dataset_content_type
      t.integer :dataset_file_size
      t.datetime :dataset_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :genetic_data
  end
end
