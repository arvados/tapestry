class CreateSurveySections < ActiveRecord::Migration
  def self.up
    create_table :survey_sections do |t|
      t.integer :survey_id
      t.string :name
      t.string :heading
      t.integer :previous_section_id
      t.integer :next_section_id
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_sections
  end
end
