class AddBadEmailToNamedProxies < ActiveRecord::Migration
  def self.up
    add_column :named_proxies, :bad_email, :boolean, :default => false
    add_column :named_proxy_versions, :bad_email, :boolean
  end

  def self.down
    remove_column :named_proxy_versions, :bad_email
    remove_column :named_proxies, :bad_email
  end
end
