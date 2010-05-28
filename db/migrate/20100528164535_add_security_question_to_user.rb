class AddSecurityQuestionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :security_question, :string
    add_column :users, :security_answer, :string
  end

  def self.down
    remove_column :users, :security_answer
    remove_column :users, :security_question
  end
end
