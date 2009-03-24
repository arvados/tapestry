class CreateInvitedEmails < ActiveRecord::Migration
  def self.up
    create_table :invited_emails do |t|
      t.string :email
      t.datetime :accepted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :invited_emails
  end
end
