class CreateFamilySurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :family_survey_responses do |t|
      t.integer :birth_year
      t.string :relatives_interested_in_pgp
      t.string :monozygotic_twin
      t.string :child_situation
      t.integer :youngest_child_age

      t.timestamps
    end
  end

  def self.down
    drop_table :family_survey_responses
  end
end
