module Admin::ExamResponsesHelper
  def format_exam_response_results(exam_response)
    correct = exam_response.correct_response_count
    total   = exam_response.exam_version.exam_questions.count
    percent = 100.0 * ( correct.to_f / total.to_f )

    "#{sprintf('%0.2f', percent)}% (#{correct}/#{total})"
  end
end
