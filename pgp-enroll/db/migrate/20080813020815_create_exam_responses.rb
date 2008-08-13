class CreateExamResponses < ActiveRecord::Migration
  def self.up
    create_table :exam_responses do |t|
      t.references :user
      t.references :exam_definition
      t.timestamps
    end
  end

  def self.down
    drop_table :exam_responses
  end
end
