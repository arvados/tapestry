class CreateDistinctiveTraits < ActiveRecord::Migration
  def self.up
    create_table :distinctive_traits do |t|
      t.string :name
      t.integer :rating

      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :distinctive_traits
  end
end
