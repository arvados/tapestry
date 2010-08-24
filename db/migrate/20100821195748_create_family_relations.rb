class CreateFamilyRelations < ActiveRecord::Migration
  def self.up
    create_table :family_relations do |t|
      t.integer :user_id
      t.integer :relative_id
      t.string :relation
      t.boolean :is_confirmed
      t.timestamps
    end
  end

  def self.down
    drop_table :family_relations
  end
end
