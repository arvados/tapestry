class CreateWaitlists < ActiveRecord::Migration
  def self.up
    create_table :waitlists do |t|
      t.string :reason
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :waitlists
  end
end
