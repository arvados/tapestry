class CreateContentAreas < ActiveRecord::Migration
  def self.up
    create_table :content_areas do |t|
      t.string :title
      t.text   :description

      t.timestamps
    end
  end

  def self.down
    drop_table :content_areas
  end
end
