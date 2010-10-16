class CreateConditions < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :description, :string
      t.column :codes, :string
      t.column :status, :string
    end
  end

  def self.down
    drop_table :conditions
  end
end
