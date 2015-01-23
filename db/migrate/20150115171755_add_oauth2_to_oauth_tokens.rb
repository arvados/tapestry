class AddOauth2ToOauthTokens < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :oauth2_token_hash, :text
  end

  def self.down
    remove_column :oauth_tokens, :oauth2_token_hash
  end
end
