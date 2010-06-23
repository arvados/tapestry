class MakeEnrollmentStepChanges < ActiveRecord::Migration
  def self.up
    # Insert a new step to show the eligibility results
    execute "UPDATE enrollment_steps set ordinal=ordinal+1 where ordinal>2"
    execute "INSERT INTO enrollment_steps (keyword, ordinal, title, description, duration) values ('screening_survey_results',3,'Eligibility Questionnaire Results','Eligibility Questionnaire Results','instant')"
    # Change duration for the consent review step
    execute "UPDATE enrollment_steps set duration='30 minutes' where keyword='consent_review'"
    # Change step 6 to 'enrollment queue'
    execute "UPDATE enrollment_steps set duration='4-6 weeks',keyword='enrollment_queue',title='Enrollment Queue',description='Enrollment Queue' where keyword='screening_submission'"
    # Drop other steps
    execute "DELETE from enrollment_steps where keyword='eligibility_screening_results'"
    execute "DELETE from enrollment_steps where ordinal>=9 and ordinal <=12"
    execute "UPDATE enrollment_steps set ordinal='11' where keyword='enrollment_application'"
    execute "UPDATE enrollment_steps set ordinal='12',keyword='enrollment_application_results',duration='1-2 months'  where keyword='eligibility_application_results'"
    # Change ordinal for 'Consent to participate' step
    execute "UPDATE enrollment_steps set ordinal='7', duration='30-60 minutes' where keyword='participation_consent'"
end

  def self.down
    # Remove eligibility results step
    execute "DELETE FROM enrollment_steps where ordinal=3"
    execute "UPDATE enrollment_steps set ordinal=ordinal-1 where ordinal>3"
    # Change duration for the consent review step
    execute "UPDATE enrollment_steps set duration='20 minutes' where keyword='consent_review'"
    # Revert step 6 to 'Submit Eligibility Screening'
    execute "UPDATE enrollment_steps set duration='1 minute',keyword='screening_submission',title='Submit Eligibility Screening',description='Submit Eligibility Screening' where keyword='enrollment_queue'"
    # Restore deleted steps
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('2-4 weeks','eligibility_screening_results',6,'Eligibility Screening Results','Eligibility Screening Results')"
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('1 hour','phr',8,'Personalized Health Record','Share your personalized health record')"
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('2 minutes','trait_collection',9,'Baseline Traits Survey','Collect your baseline traits')"
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('1 minute','pledge',10,'Make Financial Pledge','Make Financial Pledge')"
    execute "INSERT INTO enrollment_steps (duration, keyword, ordinal, title, description) values ('1 hour','distinctive_traits_survey',11,'Distinctive traits survey','Enter detailed traits')"
    execute "UPDATE enrollment_steps set ordinal='12' where keyword='enrollment_application'"
    execute "UPDATE enrollment_steps set ordinal='13',keyword='eligibility_application_results',duration='2-4 weeks' where keyword='enrollment_application_results'"
    # Change ordinal for 'Consent to participate' step
    execute "UPDATE enrollment_steps set ordinal='7', duration='5 minutes' where keyword='participation_consent'"
  end
end
