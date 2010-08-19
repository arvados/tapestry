class CreateDocument < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :keyword
      t.integer :user_id
      t.string :version
      t.datetime :timestamp, :default => nil
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
