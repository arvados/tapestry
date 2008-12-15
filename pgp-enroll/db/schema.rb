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

ActiveRecord::Schema.define(:version => 20081214221403) do

  create_table "answer_options", :force => true do |t|
    t.integer  "exam_question_id"
    t.string   "answer"
    t.boolean  "correct"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answer_options", ["exam_question_id"], :name => "index_answer_options_on_exam_question_id"

  create_table "content_areas", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordinal"
  end

  create_table "enrollment_step_completions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "enrollment_step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrollment_step_completions", ["user_id"], :name => "index_enrollment_step_completions_on_user_id"
  add_index "enrollment_step_completions", ["enrollment_step_id"], :name => "index_enrollment_step_completions_on_enrollment_step_id"

  create_table "enrollment_steps", :force => true do |t|
    t.string   "keyword"
    t.integer  "ordinal"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  add_index "exam_responses", ["user_id"], :name => "index_exam_responses_on_user_id"
  add_index "exam_responses", ["exam_version_id"], :name => "index_exam_responses_on_exam_version_id"
  add_index "exam_responses", ["original_user_id"], :name => "index_exam_responses_on_original_user_id"

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

  create_table "question_responses", :force => true do |t|
    t.integer  "exam_response_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "exam_question_id"
  end

  add_index "question_responses", ["exam_response_id"], :name => "index_question_responses_on_exam_response_id"
  add_index "question_responses", ["exam_question_id"], :name => "index_question_responses_on_exam_question_id"

  create_table "residency_survey_responses", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "us_resident"
    t.string   "country"
    t.boolean  "contact_when_pgp_opens_outside_us"
    t.string   "zip"
    t.boolean  "can_travel_to_boston"
    t.boolean  "contact_when_boston_travel_facilitated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "residency_survey_responses", ["user_id"], :name => "index_residency_survey_responses_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.boolean  "is_admin"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
  end

end
