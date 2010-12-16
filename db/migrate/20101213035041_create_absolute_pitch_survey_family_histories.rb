class CreateAbsolutePitchSurveyFamilyHistories < ActiveRecord::Migration
  def self.up
    create_table :absolute_pitch_survey_family_histories do |t|
      t.column :user_id, :int
      t.column :survey_id, :int
      t.column :relation, :string
      t.column :plays_instrument, :string
      t.column :has_absolute_pitch, :string
      t.column :comments, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :absolute_pitch_survey_family_histories
  end
end
