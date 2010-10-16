class CreateDemographics < ActiveRecord::Migration
  def self.up
    create_table :demographics do |t|
      t.column :ccr_id, :integer
      t.column :dob, :date
      t.column :gender, :string
      t.column :weight_oz, :decimal
      t.column :height_in, :decimal
      t.column :blood_type, :string
      t.column :race, :string
    end
  end

  def self.down
    drop_table :demographics
  end
end
