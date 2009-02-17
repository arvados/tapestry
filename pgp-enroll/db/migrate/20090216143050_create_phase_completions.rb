class CreatePhaseCompletions < ActiveRecord::Migration
  def self.up
    create_table :phase_completions do |t|
      t.string :phase
      t.references :user
      t.timestamps
    end

    add_index :phase_completions, :user_id
  end

  def self.down
    drop_table :phase_completions
  end
end
