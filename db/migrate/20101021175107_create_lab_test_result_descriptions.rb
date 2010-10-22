class CreateLabTestResultDescriptions < ActiveRecord::Migration
  def self.up
    create_table :lab_test_result_descriptions do |t|
      t.string :description, :null => false
    end
    add_index :lab_test_result_descriptions, :description, :unique => true
    add_column :lab_test_results, :lab_test_result_description_id, :integer
    add_index :lab_test_results, :lab_test_result_description_id
    remove_column :lab_test_results, :description
  end

  def self.down
    add_column :lab_test_results, :description, :string
    remove_index :lab_test_results, :column => :lab_test_result_description_id
    remove_column :lab_test_results, :lab_test_result_description_id
    remove_index :lab_test_result_descriptions, :column => :description
    drop_table :lab_test_result_descriptions
  end
end
