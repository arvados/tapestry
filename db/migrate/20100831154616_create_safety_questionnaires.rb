class CreateSafetyQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :safety_questionnaires do |t|
      t.integer :user_id
      t.timestamp :datetime
      t.boolean :changes
      t.text :events
      t.text :reactions
      t.text :contact
      t.text :healthcare

      t.timestamps
    end
  end

  def self.down
    drop_table :safety_questionnaires
  end
end
