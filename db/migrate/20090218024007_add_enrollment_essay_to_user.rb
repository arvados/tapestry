class AddEnrollmentEssayToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :enrollment_essay, :text
  end

  def self.down
    remove_column :users, :enrollment_essay
  end
end
