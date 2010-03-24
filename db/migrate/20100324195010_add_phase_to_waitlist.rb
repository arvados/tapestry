class AddPhaseToWaitlist < ActiveRecord::Migration
  def self.up
    add_column :waitlists, :phase, :string, :default => "preenroll", :null => false
  end

  def self.down
    remove_column :waitlists, :phase
  end
end
