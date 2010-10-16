class CreateCcrs < ActiveRecord::Migration
  def self.up
    create_table :ccrs do |t|
      t.column :user_id, :integer
      t.column :version, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :ccrs
  end
end
