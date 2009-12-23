class CreateQuestionResponses < ActiveRecord::Migration
  def self.up
    create_table :question_responses do |t|
      t.references :exam_response
      t.references :answer_option

      t.timestamps
    end
  end

  def self.down
    drop_table :question_responses
  end
end
