class CreateBaselineTraitsSurveys < ActiveRecord::Migration
  def self.up
    create_table :baseline_traits_surveys do |t|
      t.integer :user_id

      t.string  "sex"
      t.boolean "health_insurance", :default => false, :null => false
      t.boolean "health_or_medical_conditions", :default => false, :null => false
      t.boolean "prescriptions_in_last_year", :default => false, :null => false
      t.boolean "allergies", :default => false, :null => false

      t.boolean "asian", :default => false, :null => false
      t.boolean "black", :default => false, :null => false
      t.boolean "hispanic", :default => false, :null => false
      t.boolean "native", :default => false, :null => false
      t.boolean "pacific", :default => false, :null => false
      t.boolean "white", :default => false, :null => false

      t.string "birth_year"
      t.boolean "us_citizen", :default => false, :null => false

      t.string "birth_country"

      t.string "paternal_grandfather_born_in"
      t.string "paternal_grandmother_born_in"
      t.string "maternal_grandfather_born_in"
      t.string "maternal_grandmother_born_in"

      t.timestamps
    end
  end

  def self.down
    drop_table :baseline_traits_surveys
  end
end
