class CreateProcedures < ActiveRecord::Migration
  def self.up
    create_table :procedures do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :description, :string
      t.column :codes, :string
    end
  end

  def self.down
    drop_table :procedures
  end
end
