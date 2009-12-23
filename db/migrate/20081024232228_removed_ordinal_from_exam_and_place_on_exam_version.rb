class RemovedOrdinalFromExamAndPlaceOnExamVersion < ActiveRecord::Migration
  def self.up
    remove_column :exams, :ordinal
    add_column :exam_versions, :ordinal, :integer
    ActiveRecord::Base.connection.update('update exam_versions set ordinal = id')
  end

  def self.down
    remove_column :exam_versions, :ordinal
    add_column :exams, :ordinal, :integer
  end
end
