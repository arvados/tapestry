class FixDescriptionForEnrollmentStepEntranceExam < ActiveRecord::Migration
  NEW = "In this step, you will take an exam which consists of several short quizzes."
  OLD = "In this step, you take an entrance exam which consists of four content areas."

  def self.up
    update "update enrollment_steps set description='#{NEW}' where keyword='content_areas'";
  end

  def self.down
    update "update enrollment_steps set description='#{OLD}' where keyword='content_areas'";
  end
end
