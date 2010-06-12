class CreateUserLogs < ActiveRecord::Migration
  def self.up
    create_table :user_logs do |t|
      t.references :user
      t.references :enrollment_step
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :user_logs
  end
end
