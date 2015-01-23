class AddOauth2UrlsToOauthServices < ActiveRecord::Migration
  def self.up
    add_column :oauth_services, :endpoint_url, :string
    add_column :oauth_services, :callback_url, :string
  end

  def self.down
    remove_column :oauth_services, :callback_url
    remove_column :oauth_services, :endpoint_url
  end
end
