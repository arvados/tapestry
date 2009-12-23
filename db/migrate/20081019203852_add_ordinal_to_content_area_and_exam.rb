class AddOrdinalToContentAreaAndExam < ActiveRecord::Migration
  def self.up
    add_column :content_areas, :ordinal, :integer
    add_column :exams, :ordinal, :integer

    ActiveRecord::Base.connection.update('update content_areas set ordinal = id')
    ActiveRecord::Base.connection.update('update exams set ordinal = id')
  end

  def self.down
    remove_column :content_areas, :ordinal
    remove_column :exams, :ordinal
  end
end
