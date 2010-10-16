class CreateAllergies < ActiveRecord::Migration
  def self.up
    create_table :allergies do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :description, :string
      t.column :severity, :string
      t.column :codes, :string
      t.column :status, :string
    end
  end

  def self.down
    drop_table :allergies
  end
end
