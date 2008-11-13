class FixDescriptionForContentAreasEnrollmentStep < ActiveRecord::Migration
  def self.up
    update "update enrollment_steps set description='In this step, you take an entrance exam which consists of four content areas.' where keyword='content_areas'";
  end

  def self.down
    update "update enrollment_steps set description='In this step, you take an entrance exam which consists of three to four content areas.' where keyword='content_areas'";
  end
end
