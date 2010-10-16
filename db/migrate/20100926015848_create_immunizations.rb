class CreateImmunizations < ActiveRecord::Migration
  def self.up
    create_table :immunizations do |t|
      t.column :ccr_id, :integer
      t.column :start_date, :date
      t.column :name, :string
      t.column :codes, :string
    end
  end

  def self.down
    drop_table :immunizations
  end
end
