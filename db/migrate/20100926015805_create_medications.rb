class CreateMedications < ActiveRecord::Migration
  def self.up
    create_table :medications do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :name, :string
      t.column :codes, :string
      t.column :strength, :string
      t.column :dose, :string
      t.column :frequency, :string
      t.column :route, :string
      t.column :route_codes, :string
      t.column :status, :string
    end
  end

  def self.down
    drop_table :medications
  end
end
