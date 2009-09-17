class AddResubmittedAtToWaitlist < ActiveRecord::Migration
  def self.up
    add_column :waitlists, :resubmitted_at, :datetime
  end

  def self.down
    remove_column :waitlists, :resubmitted_at
  end
end
