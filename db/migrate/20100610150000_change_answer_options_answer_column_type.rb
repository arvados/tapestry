class ChangeAnswerOptionsAnswerColumnType < ActiveRecord::Migration
  def self.up
    change_column :answer_options, :answer, :text
  end

  def self.down
    change_column :answer_options, :answer, :string
  end
end
