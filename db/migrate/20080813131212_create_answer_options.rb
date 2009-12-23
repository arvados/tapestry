class CreateAnswerOptions < ActiveRecord::Migration
  def self.up
    create_table :answer_options do |t|
      t.references :exam_question
      t.string     :answer
      t.boolean    :correct
      t.timestamps
    end
  end

  def self.down
    drop_table :answer_options
  end
end
