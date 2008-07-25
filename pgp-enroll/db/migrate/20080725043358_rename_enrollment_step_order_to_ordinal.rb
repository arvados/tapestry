class RenameEnrollmentStepOrderToOrdinal < ActiveRecord::Migration
  def self.up
    rename_column :enrollment_steps, :order, :ordinal
  end

  def self.down
    rename_column :enrollment_steps, :ordinal, :order
  end
end
