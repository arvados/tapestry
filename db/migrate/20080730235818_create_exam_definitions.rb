class CreateExamDefinitions < ActiveRecord::Migration
  def self.up
    create_table :exam_definitions do |t|
      t.string  :title
      t.text    :description
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :exam_definitions
  end
end
