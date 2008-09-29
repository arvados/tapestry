class MoveContentAreaIdFromExamVersionToExam < ActiveRecord::Migration
  def self.up
    add_column 'exams', 'content_area_id', 'integer'
    execute 'UPDATE exams SET content_area_id = (select exam_versions.content_area_id from exam_versions where exam_versions.exam_id = exams.id)'
    remove_column 'exam_versions', 'content_area_id'
  end

  def self.down
    add_column 'exam_versions', 'content_area_id', 'integer'
    execute 'UPDATE exam_versions SET content_area_id = (select exams.content_area_id from exams where exam_versions.exam_id = exams.id)'
    remove_column 'exams', 'content_area_id'
  end
end
