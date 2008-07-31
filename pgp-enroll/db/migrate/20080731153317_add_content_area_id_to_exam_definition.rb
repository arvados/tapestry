class AddContentAreaIdToExamDefinition < ActiveRecord::Migration
  def self.up
    add_column :exam_definitions, :content_area_id, :integer
  end

  def self.down
    remove_column :exam_definitions, :content_area_id
  end
end
