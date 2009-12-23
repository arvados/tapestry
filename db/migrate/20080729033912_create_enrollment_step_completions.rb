class CreateEnrollmentStepCompletions < ActiveRecord::Migration
  def self.up
    create_table :enrollment_step_completions do |t|
      t.references :user
      t.references :enrollment_step

      t.timestamps
    end
  end

  def self.down
    drop_table :enrollment_step_completions
  end
end
