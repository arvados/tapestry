class CreateOauthTokens < ActiveRecord::Migration
  def self.up
    create_table :oauth_tokens do |t|
      t.references :user
      t.references :oauth_service
      t.string :requesttoken
      t.string :accesstoken
      t.string :nonce
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_tokens
  end
end
