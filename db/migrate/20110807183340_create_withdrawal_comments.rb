class CreateWithdrawalComments < ActiveRecord::Migration
  def self.up
    create_table :withdrawal_comments do |t|
      t.references :user
      t.text :comment
      t.timestamp :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :withdrawal_comments
  end
end
