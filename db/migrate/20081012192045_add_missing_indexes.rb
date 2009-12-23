class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index 'answer_options', 'exam_question_id'
    add_index 'exams', 'content_area_id'
    add_index 'question_responses', 'exam_response_id'
    add_index 'question_responses', 'exam_question_id'
    add_index 'exam_questions', 'exam_version_id'
    add_index 'exam_responses', 'user_id'
    add_index 'exam_responses', 'exam_version_id'
    add_index 'exam_responses', 'original_user_id'
    add_index 'exam_versions', 'exam_id'
    add_index 'enrollment_step_completions', 'user_id'
    add_index 'enrollment_step_completions', 'enrollment_step_id'
  end

  def self.down
    remove_index 'answer_options', 'exam_question_id'
    remove_index 'exams', 'content_area_id'
    remove_index 'question_responses', 'exam_response_id'
    remove_index 'question_responses', 'exam_question_id'
    remove_index 'exam_questions', 'exam_version_id'
    remove_index 'exam_responses', 'user_id'
    remove_index 'exam_responses', 'exam_version_id'
    remove_index 'exam_responses', 'original_user_id'
    remove_index 'exam_versions', 'exam_id'
    remove_index 'enrollment_step_completions', 'user_id'
    remove_index 'enrollment_step_completions', 'enrollment_step_id'
  end
end
