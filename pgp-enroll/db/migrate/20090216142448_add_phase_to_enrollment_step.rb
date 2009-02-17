class AddPhaseToEnrollmentStep < ActiveRecord::Migration
  def self.up
    add_column :enrollment_steps, :phase, :string
    ActiveRecord::Base.connection.update('update enrollment_steps set phase = "screening"')
  end

  def self.down
    remove_column :enrollment_steps, :phase
  end
end
