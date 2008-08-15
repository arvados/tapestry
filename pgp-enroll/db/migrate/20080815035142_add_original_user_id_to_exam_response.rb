class AddOriginalUserIdToExamResponse < ActiveRecord::Migration
  def self.up
    add_column :exam_responses, :original_user_id, :integer
  end

  def self.down
    remove_column :exam_responses, :original_user_id
  end
end
