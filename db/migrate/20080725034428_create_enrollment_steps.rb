# 
# are many EnrollmentStep
#  : each has a keyword, which also forms a link to a controller for actioning the step
# are many EnrollmentStepCompletions (ties user to the completion of an enrollment_step)
# is one EnrollmentStep called entrance_exam


class CreateEnrollmentSteps < ActiveRecord::Migration
  def self.up
    create_table :enrollment_steps do |t|
      t.string  :keyword
      t.integer :order
      t.string  :title
      t.text    :description

      t.timestamps
    end
  end

  def self.down
    drop_table :enrollment_steps
  end
end
