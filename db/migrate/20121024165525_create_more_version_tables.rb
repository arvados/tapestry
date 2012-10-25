class CreateMoreVersionTables < ActiveRecord::Migration

  def self.up_worker(table)
    add_column(table.to_sym, :creator_id, :integer)
    add_column(table.to_sym, :updater_id, :integer)
    add_column(table.to_sym, :deleted_at, :timestamp)
    table.singularize.camelize.constantize.create_versioned_table
    execute "update #{table} set lock_version=1 where lock_version is null"
  end

  def self.up
    up_worker('google_surveys')
    execute "insert into google_survey_versions (google_survey_id,lock_version,user_id,oauth_service_id,spreadsheet_key,userid_hash_secret,userid_populate_entry,userid_response_column,last_downloaded_at,created_at,updated_at,name,form_url,open,description,is_result_public,is_listed,creator_id,updater_id,deleted_at) select id,lock_version,user_id,oauth_service_id,spreadsheet_key,userid_hash_secret,userid_populate_entry,userid_response_column,last_downloaded_at,created_at,updated_at,name,form_url,open,description,is_result_public,is_listed,creator_id,updater_id,deleted_at from google_surveys"
    up_worker('google_survey_questions')
    execute " insert into google_survey_question_versions (google_survey_question_id,lock_version,google_survey_id,`column`,question,created_at,updated_at,is_hidden,creator_id,updater_id,deleted_at) select id,lock_version,google_survey_id,`column`,question,created_at,updated_at,is_hidden,creator_id,updater_id,deleted_at from google_survey_questions"
    up_worker('google_survey_answers')
    execute "insert into google_survey_answer_versions (google_survey_answer_id,lock_version,google_survey_id,`column`,answer,created_at,updated_at,nonce_id,creator_id,updater_id,deleted_at) select id,lock_version,google_survey_id,`column`,answer,created_at,updated_at,nonce_id,creator_id,updater_id,deleted_at from google_survey_answers"
    up_worker('nonces')
    execute "insert into nonce_versions (nonce_id,lock_version,owner_id,nonce,created_at,used_at,updated_at,owner_class,target_id,target_class,creator_id,updater_id,deleted_at) select id,lock_version,owner_id,nonce,created_at,used_at,updated_at,owner_class,target_id,target_class,creator_id,updater_id,deleted_at from nonces"
  end

  def self.down_worker(table)
    table.singularize.camelize.constantize.drop_versioned_table
    remove_column(table.to_sym, :creator_id)
    remove_column(table.to_sym, :updater_id)
    remove_column(table.to_sym, :deleted_at)
  end

  def self.down
    down_worker('google_surveys')
    down_worker('google_survey_questions')
    down_worker('google_survey_answers')
    down_worker('nonces')
  end
end

