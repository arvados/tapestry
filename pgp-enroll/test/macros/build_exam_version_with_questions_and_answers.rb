class Test::Unit::TestCase

  def build_exam_version_with_questions_and_answers
    exam_version = Factory(:exam_version)
    5.times do
      question = Factory(:exam_question, :exam_version => exam_version)
      5.times do |i|
        answer_option = Factory(:answer_option, :exam_question => question, :correct => i.zero?)
      end
    end
    exam_version.update_attributes({:published => true})
    exam_version
  end

end
