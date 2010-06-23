class CreateNamedProxies < ActiveRecord::Migration
  def self.up
    create_table :named_proxies do |t|
      t.references :user
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :named_proxies
  end
end
