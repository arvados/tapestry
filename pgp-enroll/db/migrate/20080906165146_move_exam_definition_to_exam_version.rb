class MoveExamDefinitionToExamVersion < ActiveRecord::Migration
  def self.up
    self.create_exams_table
    self.change_exam_definitions_to_versions
    self.create_and_associate_an_exam_for_each_exam_version
  end

  def self.create_exams_table
    create_table :exams do |t|
      t.references :published_version
      t.timestamps
    end
  end

  def self.change_exam_definitions_to_versions
    # It's okay to remove this, since parent_id functionality was never exposed to the UI
    rename_table  'exam_definitions', 'exam_versions'
    remove_column 'exam_versions',    'parent_id'
    add_column    'exam_versions',    'exam_id', :integer
    add_column    'exam_versions',    'version', :integer
    rename_column 'exam_questions',   'exam_definition_id', 'exam_version_id'
    rename_column 'exam_responses',   'exam_definition_id', 'exam_version_id'
  end

  def self.create_and_associate_an_exam_for_each_exam_version
    execute 'INSERT INTO exams (published_version_id, created_at, updated_at) SELECT id, created_at, updated_at FROM exam_versions'
    execute 'UPDATE exam_versions SET exam_id = (select exams.id from exams where exams.published_version_id = exam_versions.id)'
    execute 'UPDATE exam_versions SET version = 1'
  end

  def self.down
    remove_column 'exam_versions',    'version'
    remove_column 'exam_versions',    'exam_id'
    rename_column 'exam_questions',   'exam_version_id', 'exam_definition_id'
    rename_column 'exam_responses',   'exam_version_id', 'exam_definition_id'
    rename_table  'exam_versions',    'exam_definitions'
    add_column    'exam_definitions', 'parent_id', :integer
    drop_table :exams
  end
end
