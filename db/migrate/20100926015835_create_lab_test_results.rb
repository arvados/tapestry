class CreateLabTestResults < ActiveRecord::Migration
  def self.up
    create_table :lab_test_results do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :description, :string
      t.column :codes, :string
      t.column :value, :string
      t.column :units, :string
    end
  end

  def self.down
    drop_table :lab_test_results
  end
end
