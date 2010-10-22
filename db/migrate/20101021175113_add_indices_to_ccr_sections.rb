class AddIndicesToCcrSections < ActiveRecord::Migration
  def self.up
    add_index :conditions, :ccr_id
    add_index :medications, :ccr_id
    add_index :allergies, :ccr_id
    add_index :procedures, :ccr_id
    add_index :lab_test_results, :ccr_id
    add_index :immunizations, :ccr_id
  end

  def self.down
    remove_index :immunizations, :ccr_id
    remove_index :lab_test_results, :ccr_id
    remove_index :procedures, :ccr_id
    remove_index :allergies, :ccr_id
    remove_index :medications, :ccr_id
    remove_index :conditions, :ccr_id   
  end
end
