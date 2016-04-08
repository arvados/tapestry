Factory.define(:user) do |f|
  f.first_name            'Jason'
  f.last_name             'Morrison'
  f.pgp_id                { Factory.next :pgp_id }
  f.email                 { Factory.next :email }
  f.security_question     'security_question'
  f.security_answer       'security_answer'
  f.password              'password'
  f.password_confirmation 'password'
end

Factory.define(:activated_user, :class => :user) do |f|
  f.first_name            'Jason'
  f.last_name             'Morrison'
  f.pgp_id                { Factory.next :pgp_id }
  f.email                 { Factory.next :email }
  f.security_question     'security_question'
  f.security_answer       'security_answer'
  f.password              'password'
  f.password_confirmation 'password'
  f.activated_at { Time.now }
end

Factory.define(:admin_user, :class => User) do |f|
  f.first_name            'Jason'
  f.last_name             'Morrison'
  f.pgp_id                { Factory.next :pgp_id }
  f.email                 { Factory.next :email }
  f.security_question     'security_question'
  f.security_answer       'security_answer'
  f.password              'password'
  f.password_confirmation 'password'
  f.is_admin              true
end

Factory.define(:researcher, :class => User) do |f|
  f.first_name             'Rosalind'
  f.last_name              'Franklin'
  f.email                  { Factory.next :email }
  f.security_question      'security_question'
  f.security_answer        'security_answer'
  f.password               'password'
  f.password_confirmation  'password'
  f.researcher             true
  f.researcher_affiliation "King's College"
end

FactoryGirl.define do
  factory :enrolled_user, :class => User do |f|
    f.first_name             'George'
    f.last_name              'Church'
    f.email                  { Factory.next :email }
    f.security_question      'security_question'
    f.security_answer        'security_answer'
    f.password               'password'
    f.password_confirmation  'password'
    f.researcher             false
    f.is_admin               false
    after_create do |u|
      u.activate!
      u.accept_tos if APP_CONFIG['ensure_tos']
      u.enrolled = Time.now
      u.documents << Document.new(:keyword => 'consent',
                                  :version => APP_CONFIG['latest_consent_version'],
                                  :timestamp => Time.now())
      u.hex = Factory.next(:hex)
    end
  end
end

Factory.sequence(:email) { |n| "person#{n}@example.org" }

Factory.sequence(:pgp_id, 1000) { |n| "#{n}" }

Factory.sequence(:enrollment_step_ordinal) { |n| n }

Factory.sequence(:hex) { |n| "hex#{n}"}

%w(keyword title description).each do |attr|
  Factory.sequence("enrollment_step_#{attr}".to_sym) { |n| "#{attr.upcase} #{n}" }
end

Factory.define(:enrollment_step) do |f|
  f.keyword     { Factory.next :enrollment_step_keyword }
  f.ordinal     { Factory.next :enrollment_step_ordinal }
  f.title       { Factory.next :enrollment_step_title   }
  f.description { Factory.next :enrollment_step_description }
  f.duration "5 minutes"
end

# Is there a better way?  These enrollment_step are necessary, and torn down before tests.
# These are not in any particular order, AFAIK
# TODO: FIXME - this breaks rake:db:migrate when you have a blank database. Why? Ward, 2011-05-03
#%w(signup content_areas screening_surveys consent_review screening_submission
#   participation_consent eligibility_screening_results phr trait_collection
#   pledge identity_confirmation enrollment_application
#   distinctive_traits_survey).each do |step|
#  Factory(:enrollment_step,
#          :keyword     => step,
#          :title       => step,
#          :description => step)
#end

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

FactoryGirl.define do
  factory :dataset do
    initialize_with do
      u = Factory(:enrolled_user)
      u.save!
      Dataset.create!(:released_to_participant => true,
                      :published_at => nil,
                      :published_anonymously_at => nil,
                      :participant => u,
                      :human_id => u.hex)
    end
  end
  trait :published do
    released_to_participant true
    published_at            Time.now
  end
end

Factory.define(:user_file) do |f|
  f.name              'test user_file'
  f.data_type         'other'
  f.other_data_type   'just for testing'
  f.dataset_file_size 1234
  f.locator           'acbd18db4cc2f85cedef654fccc4a4d8+3'
  f.association       :user
end

FactoryGirl.define do
  factory :dataset_report do
    display_url 'https://example.org/dataset_report/1234'
  end
  trait :for_user_file do
    user_file { Factory(:user_file) }
  end
  trait :for_published_dataset do
    dataset   { FactoryGirl.create(:dataset, :published) }
  end
  trait :for_unpublished_dataset do
    dataset   { FactoryGirl.create(:dataset) }
  end
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

Factory.define(:screening_survey_response) do |f|
  f.user { |u| u.association :user }
  f.citizen true
  f.age_majority true
  f.monozygotic_twin 'no'
  f.worrisome_information_comfort_level 'understand'
  f.information_disclosure_comfort_level 'understand'
  f.past_genetic_test_participation 'public'
end

Factory.define(:residency_survey_response) do |f|
  f.user { |u| u.association :user }
  f.resident true
  f.zip '12345'
  f.can_travel_to_pgphq true
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
  f.resident false
  f.country 'Canada'
  f.can_travel_to_pgphq false
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


Factory.define :informed_consent_response do |f|
  f.user { |u| u.association :user }
  f.recontact 0
  f.twin 0
end

Factory.define :invited_email do |f|
  f.email { Factory.next :email }
end

Factory.define :waitlist do |f|
  f.association :user
end

Factory.define :distinctive_trait do |f|
  f.name "Swimming"
  f.rating 5
  f.association :user
end

Factory.define :baseline_traits_survey do |f|
  f.association :user
  f.sex "Male"

  ["health_insurance", "health_or_medical_conditions", "prescriptions_in_last_year", "allergies",
   "asian", "black", "hispanic", "native", "pacific", "white", "citizen"].each do |boolean|
    f.send(boolean, true)
  end

  f.birth_year 1990
  f.birth_country "United States"

  f.paternal_grandfather_born_in "France"
  f.paternal_grandmother_born_in "Germany"
  f.maternal_grandfather_born_in "Poland"
  f.maternal_grandmother_born_in "England"
end

Factory.sequence(:list_name) {|n| "Mailing List #{n}"}

Factory.define(:mailing_list) do |f|
  f.name       { Factory.next(:list_name) }
end

Factory.define(:named_proxy) do |f|
  f.user { |u| u.association :user }
  f.name "John E Miles"
  f.email "test@example.com"
end

Factory.sequence(:device_type_name) {|n| "Device Type #{n}"}
Factory.define(:device_type) do |f|
  f.name { Factory.next :device_type_name }
end

Factory.sequence(:tissue_type_name) {|n| "Device Type #{n}"}
Factory.define(:tissue_type) do |f|
  f.name { Factory.next :tissue_type_name }
end

Factory.sequence(:unit_name) {|n| "Device Type #{n}"}
Factory.define(:unit) do |f|
  f.name { Factory.next :unit_name }
end

Factory.define(:google_survey) do |f|
  f.description "My glorious description"
  f.association :user
  f.creator {|g| g.association :user}
end

Factory.sequence(:study_name) {|n| "Study #{n}"}
Factory.define(:study) do |f|
  f.name { Factory.next :study_name }
  f.researcher { Factory(:user) }
  f.participant_description "participant_description"
  f.researcher_description "researcher_description"
end

Factory.sequence(:kit_design_name) {|n| "Kit design #{n}"}
Factory.define(:kit_design) do |f|
  f.name { Factory.next :kit_design_name }
  f.study { Factory(:study) }
  f.description "My glorious description"
  f.owner {|k| k.association :user }
  f.instructions_file_name 'filename'
end

Factory.sequence(:sample_type_name) {|n| "Sample type #{n}"}
Factory.define(:sample_type) do |f|
  f.name { Factory.next :sample_type_name }
  f.description "Description"
  f.target_amount 100
  f.tissue_type { Factory(:tissue_type) }
  f.device_type { Factory(:device_type) }
  f.unit        { Factory(:unit) }
end

Factory.sequence(:sample_crc_id) {|n| Kit.generate_verhoeff_number Sample.new }
Factory.sequence(:url_code) {|n| "URL code #{n}"}

Factory.define(:sample) do |f|
  f.crc_id   { Factory.next :sample_crc_id }
  f.url_code { Factory.next :url_code }
  f.study    { Factory(:study) }
end

Factory.define(:kit_design_sample) do |f|
  f.name "My kit design sample name"
  f.sort_order 1
  f.association :kit_design
end

Factory.sequence(:kit_name) {|n| "Kit #{n}"}
Factory.sequence(:kit_crc_id) {|n| Kit.generate_verhoeff_number Kit.new }

Factory.define(:kit) do |f|
  f.name { Factory.next :kit_name }
  f.crc_id { Factory.next :kit_crc_id }
  f.url_code { Factory.next :url_code }
  f.study        { Factory(:study) }
  f.kit_design   { Factory(:kit_design) }
#  f.owner
end

Factory.define(:oauth_service) do |f|
  f.name "My name"
  f.scope "A scope"
  f.consumerkey "A consumer key"
  f.privatekey "A private key"
end

Factory.define(:plate_layout) {}

Factory.define(:plate) do |f|
  f.crc_id { Factory.next :crc_id }
  f.url_code { Factory.next :url_code }
  f.plate_layout { Factory(:plate_layout) }
end

Factory.define(:removal_request) do |f|
  f.user { Factory(:user) }
end

Factory.define(:shipping_address) do |f|
  f.address_line_1 "My address"
  f.city "My city"
  f.state "My state"
  f.zip "12345"
  f.phone "(111) 555-3333"
  f.association :user
end

Factory.define(:safety_questionnaire) do |f|
  f.datetime { Time.now }
  f.has_changes 1
  f.association :user
end

Factory.define(:document) do |f|
  f.timestamp { Time.now }
  f.association :user
end

Factory.define(:unused_kit_name) do |f|
end

Factory.define(:withdrawal_comment) do |f|
end

Factory.define(:open_humans_oauth_service, :class => OauthService) do |f|
  f.oauth2_service_type OauthService::OPEN_HUMANS
end

Factory.define(:open_humans_token, :class => OauthToken) do |f|
  f.oauth_service { |s| s.association :open_humans_oauth_service  }
  f.oauth2_token_hash( { :expires_at => (Time.now + 1.hour).to_i }.to_yaml )
end

Factory.define(:google_oauth_service, :class => OauthService) do |f|
  f.name 'Google Docs'
  f.oauth2_service_type OauthService::GOOGLE
end

Factory.define(:google_oauth_token, :class => OauthToken) do |f|
  f.oauth_service { |s| s.association :google_oauth_service  }
  f.oauth2_token_hash( { :expires_at => (Time.now + 1.hour).to_i }.to_yaml )
  f.user { Factory(:researcher) }
end

Factory.define(:active_third_party_study, :class => Study) do |f|
  f.name "An active third-party study"
  f.requested true
  f.approved true
  f.open true
  f.participation_url "http://third-party-study.example/pgp_landing_page"
  f.participant_description "You can sign up for this study and be studied."
  f.researcher_description "This study studies stuff about participants."
  f.researcher { Factory(:researcher) }
  f.irb_associate { Factory(:researcher) }
end
