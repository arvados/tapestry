require 'factory_girl'

Factory.define(:user) do |f|
  f.first_name            'Jason'
  f.last_name             'Morrison'
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
end

Factory.define(:admin_user, :class => User) do |f|
  f.first_name            'Jason'
  f.last_name             'Morrison'
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
  f.is_admin              true
end

Factory.sequence(:email) { |n| "person#{n}@example.org" }

Factory.sequence(:enrollment_step_ordinal) { |n| n }

%w(keyword title description).each do |attr|
  Factory.sequence("enrollment_step_#{attr}".to_sym) { |n| "#{attr.upcase} #{n}" }
end

Factory.define(:enrollment_step) do |f|
  f.keyword     { Factory.next :enrollment_step_keyword }
  f.ordinal     { Factory.next :enrollment_step_ordinal }
  f.title       { Factory.next :enrollment_step_title   }
  f.description { Factory.next :enrollment_step_description }
end

# Is there a better way?  These enrollment_step are necessary, and torn down before tests.
Factory(:enrollment_step,
        :keyword     => 'signup',
        :title       => 'Consent to take entrance exam',
        :description => 'In this step, you sign up for an account and agree to the mini consent form.')

Factory(:enrollment_step,
        :keyword     => 'content_areas',
        :title       => 'Entrance exam',
        :description => 'In this step, you take an entrance exam which consists of three to four content areas.')

Factory(:enrollment_step,
        :keyword     => 'screening_surveys',
        :title       => 'SScreening Surveys',
        :description => 'Complete initial screening surveys')

Factory.define(:enrollment_step_completion) do |f|
  f.user            { |u| u.association :user }
  f.enrollment_step { |e| e.association :enrollment_step }
end

Factory.sequence(:content_area_ordinal) { |n| n }
Factory.define(:content_area) do |f|
  f.title       'Content Area Title'
  f.description 'Content Area Description'
  f.ordinal { Factory.next :content_area_ordinal }
end

Factory.define(:exam) do |f|
  f.content_area { |e| e.association :content_area }
end

Factory.sequence(:exam_version_ordinal) { |n| n }
Factory.define(:exam_version) do |f|
  f.title       'Exam Definition Title'
  f.description 'Exam Definition Description'
  f.exam        { |e| e.association :exam }
  f.version 1
  f.ordinal     { Factory.next(:exam_version_ordinal) }
end

Factory.define(:published_exam_version_with_question, :class => ExamVersion) do |f|
  f.title       'Exam Definition Title'
  f.description 'Exam Definition Description'
  f.exam        { |e| e.association :exam }
  f.published   true
  f.exam_questions { |e| [e.association(:exam_question)] }
  f.version 1
  f.ordinal     { Factory.next(:exam_version_ordinal) }
end

Factory.define(:exam_response) do |f|
  f.user         { |u| u.association :user }
  f.exam_version { |e| e.association :exam_version }
end

Factory.define(:exam_question) do |f|
  f.exam_version  { |e| e.association :exam_version }
  f.ordinal       { |q| q.exam_version.exam_questions.count }
  f.kind          'MULTIPLE_CHOICE'
end

Factory.define(:answer_option) do |f|
  f.exam_question { |q| q.association :exam_question }
  f.answer 'Answer Option'
  f.correct false
end

Factory.define(:question_response) do |f|
  f.exam_question { |q| q.association :exam_question }
  f.exam_response { |r| r.association(:exam_response, :exam_version => r.exam_question.exam_version) }
  f.answer        { |a| a.exam_question.correct_answer }
end
Factory.define(:residency_survey_response) do |f|
  f.user { |u| u.association :user }
  f.us_resident true
  f.zip '12345'
  f.can_travel_to_boston true
end

Factory.define :family_survey_response do |f|
  f.user         { |u| u.association :user }
  f.birth_year 1983
  f.relatives_interested_in_pgp '0'
  f.monozygotic_twin 'no'
  f.child_situation 'none'
end

Factory.define :privacy_survey_response do |f|
  f.user { |u| u.association :user }
  f.worrisome_information_comfort_level 'understand'
  f.information_disclosure_comfort_level 'understand'
  f.past_genetic_test_participation 'public'
end

Factory.define :ineligible_residency_survey_response, :class => ResidencySurveyResponse do |f|
  f.user { |u| u.association :user }
  f.us_resident false
  f.country 'Canada'
  f.contact_when_pgp_opens_outside_us false
  f.can_travel_to_boston false
end

Factory.define :ineligible_family_survey_response, :class => FamilySurveyResponse do |f|
  f.user         { |u| u.association :user }
  f.birth_year { Time.now.year - 1 }
  f.relatives_interested_in_pgp '0'
  f.monozygotic_twin 'no'
  f.child_situation 'none'
end

Factory.define :ineligible_privacy_survey_response, :class => PrivacySurveyResponse do |f|
  f.user { |u| u.association :user }
  f.worrisome_information_comfort_level 'uncomfortable'
  f.information_disclosure_comfort_level 'uncomfortable'
  f.past_genetic_test_participation 'no'
end

