class MoveExamPublishedVersionToExamVersionPublished < ActiveRecord::Migration
  def self.up
    add_column 'exam_versions', 'published', :boolean, :null => false, :default => false
    execute 'update exam_versions set published = ( select count(*) from exams where exams.published_version_id = exam_versions.id )'
    remove_column 'exams', 'published_version_id'
  end

  def self.down
    add_column 'exams', 'published_version_id', :integer
    execute 'update exams set published_version_id = ( select id from exam_versions where published = 1 limit 1 )'
    remove_column 'exam_versions', 'published'
  end
end
