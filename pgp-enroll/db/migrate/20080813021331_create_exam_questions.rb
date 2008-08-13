class CreateExamQuestions < ActiveRecord::Migration
  def self.up
    create_table :exam_questions do |t|
      t.references :exam_definition
      t.string     :kind
      t.integer    :ordinal
      t.string     :question

      t.timestamps
    end
  end

  def self.down
    drop_table :exam_questions
  end
end
