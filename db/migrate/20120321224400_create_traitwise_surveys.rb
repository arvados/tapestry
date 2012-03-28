class CreateTraitwiseSurveys < ActiveRecord::Migration
  def self.up
    create_table :traitwise_surveys do |t|
      t.references :user

      t.string :tags

      t.string :name
      t.boolean :open
      t.text :description
      t.boolean :is_result_public
      t.boolean :is_listed

      t.integer :creator_id
      t.integer :updater_id
      t.timestamp :deleted_at

      t.timestamps
    end
    TraitwiseSurvey.create_versioned_table
  end

  def self.down
    TraitwiseSurvey.drop_versioned_table
    drop_table :traitwise_surveys
  end
end
