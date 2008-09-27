class RenameExamQuestionTypeToKind < ActiveRecord::Migration
  def self.up
    update "update exam_questions set type='MULTIPLE_CHOICE' where type='MultipleChoiceExamQuestion'";
    update "update exam_questions set type='CHECK_ALL' where type='CheckAllExamQuestion'";
    rename_column :exam_questions, :type, :kind
  end

  def self.down
    rename_column :exam_questions, :type, :kind
    update "update exam_questions set type='MultipleChoiceExamQuestion' where type='MULTIPLE_CHOICE'";
    update "update exam_questions set type='CheckAllExamQuestion' where type='CHECK_ALL'";
  end
end
