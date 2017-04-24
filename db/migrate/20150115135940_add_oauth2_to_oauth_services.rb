class AddOauth2ToOauthServices < ActiveRecord::Migration
  def self.up
    add_column :oauth_services, :oauth2_service_type, :string
    add_column :oauth_services, :oauth2_key, :string
    add_column :oauth_services, :oauth2_secret, :text
  end

  def self.down
    remove_column :oauth_services, :oauth2_secret
    remove_column :oauth_services, :oauth2_key
    remove_column :oauth_services, :oauth2_service_type
  end
end
