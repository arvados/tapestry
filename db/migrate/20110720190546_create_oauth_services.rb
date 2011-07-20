class CreateOauthServices < ActiveRecord::Migration
  def self.up
    create_table :oauth_services do |t|
      t.string :name
      t.string :scope
      t.string :consumerkey
      t.text :privatekey

      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_services
  end
end
