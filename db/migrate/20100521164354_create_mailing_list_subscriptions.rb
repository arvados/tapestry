class CreateMailingListSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :mailing_list_subscriptions, :id => false do |t|
      t.integer :user_id
      t.integer :mailing_list_id
    end
    add_index :mailing_list_subscriptions, [ :user_id, :mailing_list_id ], :unique => true
  end

  def self.down
    remove_index :mailing_list_subscriptions, [ :user_id, :mailing_list_id ]
    drop_table :mailing_list_subscriptions
  end
end
