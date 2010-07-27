class AddExamVersionToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :exam_version, :string
    self.set_exam_version
  end

  def self.set_exam_version
    execute 'UPDATE users u set exam_version=\'v1\' where id in (select user_id from enrollment_step_completions where user_id=u.id and enrollment_step_id=2 and created_at < \'2010-07-01 00:00:00\')'
    execute 'UPDATE users u set exam_version=\'v2\' where id in (select user_id from enrollment_step_completions where user_id=u.id and enrollment_step_id=2 and created_at > \'2010-07-01 00:00:00\')'
  end

  def self.down
    remove_column :users, :exam_version
  end
end
