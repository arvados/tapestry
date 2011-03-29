# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110329163713) do

  create_table "absolute_pitch_survey_family_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.string   "relation"
    t.string   "plays_instrument"
    t.string   "has_absolute_pitch"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "allergies", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "severity"
    t.string  "codes"
    t.string  "status"
    t.integer "allergy_description_id"
  end

  add_index "allergies", ["allergy_description_id"], :name => "index_allergies_on_allergy_description_id"
  add_index "allergies", ["ccr_id"], :name => "index_allergies_on_ccr_id"

  create_table "allergy_descriptions", :force => true do |t|
    t.string "description", :null => false
  end

  add_index "allergy_descriptions", ["description"], :name => "index_allergy_descriptions_on_description", :unique => true

  create_table "answer_options", :force => true do |t|
    t.integer  "exam_question_id"
    t.text     "answer"
    t.boolean  "correct"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answer_options", ["exam_question_id"], :name => "index_answer_options_on_exam_question_id"

  create_table "baseline_traits_surveys", :force => true do |t|
    t.integer  "user_id"
    t.string   "sex"
    t.boolean  "health_insurance",             :default => false, :null => false
    t.boolean  "health_or_medical_conditions", :default => false, :null => false
    t.boolean  "prescriptions_in_last_year",   :default => false, :null => false
    t.boolean  "allergies",                    :default => false, :null => false
    t.boolean  "asian",                        :default => false, :null => false
    t.boolean  "black",                        :default => false, :null => false
    t.boolean  "hispanic",                     :default => false, :null => false
    t.boolean  "native",                       :default => false, :null => false
    t.boolean  "pacific",                      :default => false, :null => false
    t.boolean  "white",                        :default => false, :null => false
    t.string   "birth_year"
    t.boolean  "us_citizen",                   :default => false, :null => false
    t.string   "birth_country"
    t.string   "paternal_grandfather_born_in"
    t.string   "paternal_grandmother_born_in"
    t.string   "maternal_grandfather_born_in"
    t.string   "maternal_grandmother_born_in"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ccrs", :force => true do |t|
    t.integer  "user_id"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "condition_descriptions", :force => true do |t|
    t.string "description", :null => false
  end

  add_index "condition_descriptions", ["description"], :name => "index_condition_descriptions_on_description", :unique => true

  create_table "conditions", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "codes"
    t.string  "status"
    t.integer "condition_description_id"
  end

  add_index "conditions", ["ccr_id"], :name => "index_conditions_on_ccr_id"
  add_index "conditions", ["condition_description_id"], :name => "index_conditions_on_condition_description_id"

  create_table "content_areas", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinal"
  end

  create_table "demographics", :force => true do |t|
    t.integer "ccr_id"
    t.date    "dob"
    t.string  "gender"
    t.integer "weight_oz",  :limit => 10, :precision => 10, :scale => 0
    t.integer "height_in",  :limit => 10, :precision => 10, :scale => 0
    t.string  "blood_type"
    t.string  "race"
  end

  create_table "distinctive_traits", :force => true do |t|
    t.string   "name"
    t.integer  "rating"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.string   "keyword"
    t.integer  "user_id"
    t.string   "version"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrollment_step_completions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "enrollment_step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrollment_step_completions", ["enrollment_step_id"], :name => "index_enrollment_step_completions_on_enrollment_step_id"
  add_index "enrollment_step_completions", ["user_id"], :name => "index_enrollment_step_completions_on_user_id"

  create_table "enrollment_steps", :force => true do |t|
    t.string   "keyword"
    t.integer  "ordinal"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phase"
    t.string   "duration"
  end

  create_table "exam_questions", :force => true do |t|
    t.integer  "exam_version_id"
    t.string   "kind"
    t.integer  "ordinal"
    t.text     "question"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exam_questions", ["exam_version_id"], :name => "index_exam_questions_on_exam_version_id"

  create_table "exam_responses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "exam_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_user_id"
  end

  add_index "exam_responses", ["exam_version_id"], :name => "index_exam_responses_on_exam_version_id"
  add_index "exam_responses", ["original_user_id"], :name => "index_exam_responses_on_original_user_id"
  add_index "exam_responses", ["user_id"], :name => "index_exam_responses_on_user_id"

  create_table "exam_versions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exam_id"
    t.integer  "version"
    t.boolean  "published",   :default => false, :null => false
    t.integer  "ordinal"
  end

  add_index "exam_versions", ["exam_id"], :name => "index_exam_versions_on_exam_id"

  create_table "exams", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_area_id"
  end

  add_index "exams", ["content_area_id"], :name => "index_exams_on_content_area_id"

  create_table "family_relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "relative_id"
    t.string   "relation"
    t.boolean  "is_confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "family_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "birth_year"
    t.string   "relatives_interested_in_pgp"
    t.string   "monozygotic_twin"
    t.string   "child_situation"
    t.integer  "youngest_child_birth_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "family_survey_responses", ["user_id"], :name => "index_family_survey_responses_on_user_id"

  create_table "genetic_data", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                 :null => false
    t.string   "data_type",            :null => false
    t.date     "date"
    t.text     "description",          :null => false
    t.string   "dataset_file_name"
    t.string   "dataset_content_type"
    t.integer  "dataset_file_size"
    t.datetime "dataset_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "immunization_names", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "immunization_names", ["name"], :name => "index_immunization_names_on_name", :unique => true

  create_table "immunizations", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.string  "codes"
    t.integer "immunization_name_id"
  end

  add_index "immunizations", ["ccr_id"], :name => "index_immunizations_on_ccr_id"
  add_index "immunizations", ["immunization_name_id"], :name => "index_immunizations_on_immunization_name_id"

  create_table "informed_consent_responses", :force => true do |t|
    t.integer  "twin",       :limit => 1
    t.integer  "biopsy",     :limit => 1
    t.integer  "recontact",  :limit => 1
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "international_participants", :force => true do |t|
    t.string   "email"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invited_emails", :force => true do |t|
    t.string   "email"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lab_test_result_descriptions", :force => true do |t|
    t.string "description", :null => false
  end

  add_index "lab_test_result_descriptions", ["description"], :name => "index_lab_test_result_descriptions_on_description", :unique => true

  create_table "lab_test_results", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.string  "codes"
    t.string  "value"
    t.string  "units"
    t.integer "lab_test_result_description_id"
  end

  add_index "lab_test_results", ["ccr_id"], :name => "index_lab_test_results_on_ccr_id"
  add_index "lab_test_results", ["lab_test_result_description_id"], :name => "index_lab_test_results_on_lab_test_result_description_id"

  create_table "mailing_list_subscriptions", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "mailing_list_id"
  end

  add_index "mailing_list_subscriptions", ["user_id", "mailing_list_id"], :name => "index_mailing_list_subscriptions_on_user_id_and_mailing_list_id", :unique => true

  create_table "mailing_lists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medication_names", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "medication_names", ["name"], :name => "index_medication_names_on_name", :unique => true

  create_table "medications", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "codes"
    t.string  "strength"
    t.string  "dose"
    t.string  "frequency"
    t.string  "route"
    t.string  "route_codes"
    t.string  "status"
    t.integer "medication_name_id"
  end

  add_index "medications", ["ccr_id"], :name => "index_medications_on_ccr_id"
  add_index "medications", ["medication_name_id"], :name => "index_medications_on_medication_name_id"

  create_table "named_proxies", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phase_completions", :force => true do |t|
    t.string   "phase"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phase_completions", ["user_id"], :name => "index_phase_completions_on_user_id"

  create_table "privacy_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.string   "worrisome_information_comfort_level"
    t.string   "information_disclosure_comfort_level"
    t.string   "past_genetic_test_participation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "privacy_survey_responses", ["user_id"], :name => "index_privacy_survey_responses_on_user_id"

  create_table "procedure_descriptions", :force => true do |t|
    t.string "description", :null => false
  end

  add_index "procedure_descriptions", ["description"], :name => "index_procedure_descriptions_on_description", :unique => true

  create_table "procedures", :force => true do |t|
    t.integer "ccr_id"
    t.date    "start_date"
    t.string  "codes"
    t.integer "procedure_description_id"
  end

  add_index "procedures", ["ccr_id"], :name => "index_procedures_on_ccr_id"
  add_index "procedures", ["procedure_description_id"], :name => "index_procedures_on_procedure_description_id"

  create_table "question_responses", :force => true do |t|
    t.integer  "exam_response_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exam_question_id"
    t.boolean  "correct",          :default => false, :null => false
  end

  add_index "question_responses", ["correct"], :name => "index_question_responses_on_correct"
  add_index "question_responses", ["exam_question_id"], :name => "index_question_responses_on_exam_question_id"
  add_index "question_responses", ["exam_response_id"], :name => "index_question_responses_on_exam_response_id"

  create_table "residency_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "us_resident"
    t.string   "country"
    t.string   "zip"
    t.boolean  "can_travel_to_boston"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "residency_survey_responses", ["user_id"], :name => "index_residency_survey_responses_on_user_id"

  create_table "safety_questionnaires", :force => true do |t|
    t.integer  "user_id"
    t.datetime "datetime"
    t.boolean  "changes"
    t.text     "events"
    t.text     "reactions"
    t.text     "contact"
    t.text     "healthcare"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "screening_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "us_citizen_or_resident"
    t.boolean  "age_21"
    t.string   "monozygotic_twin"
    t.string   "worrisome_information_comfort_level"
    t.string   "information_disclosure_comfort_level"
    t.string   "past_genetic_test_participation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_answer_choices", :force => true do |t|
    t.integer  "survey_question_id"
    t.string   "text"
    t.string   "value"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_answer_choices", ["survey_question_id"], :name => "index_survey_answer_choices_on_survey_question_id"

  create_table "survey_answers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_question_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_answers", ["survey_question_id"], :name => "index_survey_answers_on_survey_question_id"
  add_index "survey_answers", ["user_id"], :name => "index_survey_answers_on_user_id"

  create_table "survey_questions", :force => true do |t|
    t.integer  "survey_section_id"
    t.string   "text"
    t.string   "note"
    t.string   "question_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_required"
  end

  add_index "survey_questions", ["survey_section_id"], :name => "index_survey_questions_on_survey_section_id"

  create_table "survey_sections", :force => true do |t|
    t.integer  "survey_id"
    t.string   "name"
    t.string   "heading"
    t.integer  "previous_section_id"
    t.integer  "next_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_sections", ["survey_id"], :name => "index_survey_sections_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "enrollment_step_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin"
    t.string   "user_comment"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                            :limit => 100
    t.string   "crypted_password",                 :limit => 40
    t.string   "salt",                             :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",                   :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",                  :limit => 40
    t.datetime "activated_at"
    t.boolean  "is_admin"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "phr_file_name"
    t.string   "phr_content_type"
    t.integer  "phr_file_size"
    t.datetime "phr_updated_at"
    t.integer  "pledge"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "enrollment_essay"
    t.string   "phr_profile_name"
    t.boolean  "has_sequence",                                    :default => false, :null => false
    t.string   "has_sequence_explanation"
    t.text     "family_members_passed_exam"
    t.string   "security_question"
    t.string   "security_answer"
    t.string   "eligibility_survey_version"
    t.datetime "enrolled"
    t.string   "authsub_token"
    t.string   "hex",                                             :default => ""
    t.string   "exam_version"
    t.datetime "enrollment_accepted"
    t.string   "consent_version"
    t.boolean  "is_test",                                         :default => false
    t.string   "has_family_members_enrolled"
    t.string   "pgp_id"
    t.datetime "absolute_pitch_survey_completion"
  end

  create_table "waitlists", :force => true do |t|
    t.string   "reason"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "resubmitted_at"
    t.string   "phase",          :default => "preenroll", :null => false
  end

end
