class AnswerOption < ActiveRecord::Base
end

class QuestionResponse < ActiveRecord::Base
  belongs_to :answer_option
end

class ChangeQuestionResponseAnswerOptionIdFieldToAnswerString < ActiveRecord::Migration
  def self.up
    add_column :question_responses, :exam_question_id, :integer

    QuestionResponse.all.each do |qr|
      if qr.answer_option
        qr.update_attribute(:exam_question_id, qr.answer_option.exam_question_id)
      end
    end

    rename_column :question_responses, :answer_option_id, :answer
    change_column :question_responses, :answer, :string
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
