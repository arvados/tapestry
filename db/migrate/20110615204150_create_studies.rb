class CreateStudies < ActiveRecord::Migration
  def self.up
    create_table :studies do |t|
      t.string :name
      t.text :participant_description
      t.text :researcher_description
      t.belongs_to :researcher, :class_name => User
      t.belongs_to :irb_associate, :class_name => User
      t.boolean :requested
      t.boolean :approved

      t.timestamps
    end
  end

  def self.down
    drop_table :studies
  end
end
