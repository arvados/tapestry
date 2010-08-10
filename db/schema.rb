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

ActiveRecord::Schema.define(:version => 20100810155658) do

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

  create_table "content_areas", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinal"
  end

  create_table "distinctive_traits", :force => true do |t|
    t.string   "name"
    t.integer  "rating"
    t.integer  "user_id"
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

  create_table "screening_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "us_citizen"
    t.boolean  "age_21"
    t.string   "monozygotic_twin"
    t.string   "worrisome_information_comfort_level"
    t.string   "information_disclosure_comfort_level"
    t.string   "past_genetic_test_participation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "enrollment_step_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                      :limit => 100
    t.string   "crypted_password",           :limit => 40
    t.string   "salt",                       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",             :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",            :limit => 40
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
    t.boolean  "has_sequence",                              :default => false, :null => false
    t.string   "has_sequence_explanation"
    t.text     "family_members_passed_exam"
    t.string   "security_question"
    t.string   "security_answer"
    t.string   "eligibility_survey_version"
    t.datetime "enrolled"
    t.string   "authsub_token"
    t.string   "hex",                                       :default => ""
    t.string   "exam_version"
    t.datetime "enrollment_accepted"
    t.string   "consent_version"
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
