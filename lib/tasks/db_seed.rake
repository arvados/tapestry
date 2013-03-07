namespace :db do
  desc "Add default enrollment steps"
  task :seed_enrollment_steps => :environment do
    unless EnrollmentStep.all.empty?
      raise "Enrollment steps already exist, so running db:seed_enrollment_steps is probably a mistake."
    end
    did = 0
    [[1, "screening", "signup", "5 minutes",
      "Consent for Eligibility Screening",
      "In this step, you sign up for an account and agree to the mini consent form."],
     [2, "screening", "screening_surveys", "10 minutes",
      "Eligibility Questionnaire",
      "Complete initial screening surveys."],
     [3, nil, "screening_survey_results", "instant",
      "Eligibility Questionnaire Results",
      "Eligibility Questionnaire Results"],
     [4, "screening", "content_areas", "30-90 minutes",
      "Entrance Exam",
      "In this step, you take an entrance exam which consists of four content areas."],
     [5, "screening", "consent_review", "30 minutes",
      "Review of PGP Consent Form",
      "View the consent form document and mark that you have read it."],
     [6, "preenrollment", "participation_consent", "30-60 minutes",
      "Consent to Participate",
      "Consent to Participate step."],
     [7, nil, "named_proxies", "5 minutes",
      "Name Designated Proxies",
      "Name Designated Proxies"],
     [8, nil, "baseline_trait_collection_notification", "1 minute",
      "Trait Data",
      "Trait Data"],
     [9, nil, "identity_verification_notification", "1 minute",
      "Identity Verification",
      "Identity Verification"],
     [10, "preenrollment", "enrollment_application", "1 minute",
      "Submit Enrollment Application",
      "Submit Enrollment Application"],
     [11, "preenrollment", "enrollment_application_results", "3-4 days",
      "Enrollment Application Results",
      "Enrollment Application Results"]].
      each do |ordinal, phase, keyword, duration, title, description|
      EnrollmentStep.new(:keyword => keyword,
                         :phase => phase,
                         :ordinal => ordinal,
                         :title => title,
                         :description => description,
                         :duration => duration).save!
      did += 1
    end
    puts "Added #{did} enrollment steps."
  end
end
