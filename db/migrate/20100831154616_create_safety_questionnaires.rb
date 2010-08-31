class CreateSafetyQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :safety_questionnaires do |t|
      t.integer :user_id
      t.timestamp :datetime
      t.boolean :changes
      t.string :events
      t.string :reactions
      t.string :contact
      t.string :healthcare

      t.timestamps
    end
  end

  def self.down
    drop_table :safety_questionnaires
  end
end
