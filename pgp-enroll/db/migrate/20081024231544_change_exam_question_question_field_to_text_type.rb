class ChangeExamQuestionQuestionFieldToTextType < ActiveRecord::Migration
  def self.up
    change_column :exam_questions, :question, :text
  end

  def self.down
    change_column :exam_questions, :question, :string
  end
end
