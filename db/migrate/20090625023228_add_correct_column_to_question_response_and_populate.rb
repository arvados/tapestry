class AddCorrectColumnToQuestionResponseAndPopulate < ActiveRecord::Migration
  def self.up
    add_column :question_responses, :correct, :boolean, :default => false, :null => false
    add_index :question_responses, :correct

    n = 0
    total = QuestionResponse.count
    question_responses = {}
    group_size = 10_000
    start_time = Time.now

    ids = QuestionResponse.connection.select_values("select id from question_responses")

    ids.each_slice(group_size) do |id_slice|
      QuestionResponse.transaction do
        id_slice.each do |id|
          seconds = Time.now - start_time
          puts "Caching QuestionResponse#correct: #{n}/#{total} (#{n.to_f/seconds}/second)" if ( 0 == n % 100 )

          qr = QuestionResponse.find(id)
          n += 1

          is_correct = (qr.exam_question && qr.exam_question.correct_answer) ?
                       (qr.answer.to_s == qr.exam_question.correct_answer.to_s) :
                       false
          sql_correct = is_correct ? 1 : 0

          QuestionResponse.update_all("correct = #{sql_correct}", "id = #{qr.id}")
        end
      end
    end
  end

  def self.down
    remove_index :question_responses, :correct
    remove_column :question_responses, :correct
  end
end
