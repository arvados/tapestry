Tapestry::Application.routes.draw do
  resources :withdrawal_comments
  resources :permissions
  match '/permissions/update_subject_select/:subject_class', :controller=>'permissions', :action => 'update_subject_select'
  match '/permissions/update_subject_select/:subject_class/:id', :controller=>'permissions', :action => 'update_subject_select'

  resources :plates
  match '/plates/m/:url_code' => 'plates#mobile', :as => :mobile_plate, :via => :get
  match '/plates/:plate_id/assign/:plate_layout_position_id/:sample_id' => 'plates#mobile_assign_position', :as => :mobile_assign_plate_position, :via => :post
  match '/plates/:plate_id/destroy/:plate_layout_position_id' => 'plates#mobile_destroy_position', :as => :mobile_destroy_plate_position, :via => :post
  match '/plates/select_layout_mask/:url_code/:plate_layout_mask_id' => 'plates#mobile_select_layout_mask', :as => :mobile_select_plate_layout_mask, :via => :post
  match '/plates/mobile_stop/:id' => 'plates#mobile_stop', :as => :mobile_stop_plate, :via => :post
  match '/plates/:plate_id/destroy_sample/:plate_layout_position_id' => 'plates#destroy_sample', :as => :destroy_plate_sample, :via => :post

  match '/samples/receive' => 'samples#receive', :as => :receive_sample
  match '/samples/:id/log' => 'samples#show_log', :as => :show_sample_log, :via => :get
  match '/samples/:id/participant_note' => 'samples#participant_note', :as => :sample_participant_note, :via => :get
  match '/samples/:id/participant_note' => 'samples#update_participant_note', :as => :sample_update_participant_note, :via => :put
  match '/samples/:id/destroyed' => 'samples#mark_as_destroyed', :as => :sample_destroyed, :via => :post
  resources :samples
  match '/samples/:id/received' => 'samples#received', :as => :received_sample, :via => :post
  match '/samples/:crc_id/receive_by_crc_id' => 'samples#receive_by_crc_id', :as => :receive_by_crc_id_sample, :via => :post
  match '/samples/m/:url_code/undo_reception' => 'samples#mobile_undo_reception', :as => :mobile_sample_undo_reception, :via => :get
  match '/samples/m/:url_code/receive' => 'samples#mobile_receive', :as => :mobile_sample_receive, :via => :get
  match '/samples/m/:url_code' => 'samples#mobile', :as => :mobile_sample, :via => :get

  resources :unused_kit_names

  match '/kits/:id/log' => 'kits#show_log', :as => :show_kit_log, :via => :get
  match '/kits/:id/confirm_claim' => 'kits#confirm_claim', :as => :kit_confirm_claim, :via => :post
  match '/kits/claim' => 'kits#claim', :as => :kit_claim

  # TMP TO DEAL WITH DUPLICATE KIT NAME
  match '/kits/claim_danforth' => 'kits#claim_danforth', :as => :kit_claim_danforth

  resources :kits
  match '/kits/:id/sent' => 'kits#sent', :as => :sent_kit, :via => :post
  match '/kits/:id/returned' => 'kits#returned', :as => :returned_kit, :via => :post

  resources :google_surveys do
    post 'participate', :on => :member
    post 'synchronize', :on => :member
    post 'download', :on => :member
  end

  get "oauth_tokens/authorize"
  get "oauth_tokens/revoke"
  match "oauth_tokens/get_access_token" => 'oauth_tokens#get_access_token', :as => :get_oauth_access_token, :via => :get
  resources :oauth_tokens

  resources :kit_design_samples
  resources :sample_types
  resources :units
  resources :device_types
  resources :tissue_types
  resources :kit_designs
  match '/studies/claim' => 'studies#claim', :as => :study_claim_kit
  match '/studies/:id/users' => 'studies#users', :as => :study_users
  match '/studies/:id/map' => 'studies#map', :as => :study_map
  match '/studies/:study_id/users/:user_id/:status' => 'studies#update_user_status', :as => :study_update_user_status
  resources :studies

  resources :pages
  match '/' => 'pages#show', :id => 'home'
  match '/enrolled' => 'pages#show', :as => :enrolled, :id => 'enrolled'
  match '/users/initial' => 'users#initial', :as => :initial_user
  match '/users/create_initial' => 'users#create_initial', :as => :create_initial_user
  match '/users/new2' => 'users#new2', :as => :new2_user
  match '/users/accept_enrollment' => 'users#accept_enrollment', :as => :accept_enrollment_user
  match '/users/tos' => 'users#tos', :as => :tos_user
  match '/users/accept_tos' => 'users#accept_tos', :as => :accept_tos_user
  match '/users/consent' => 'users#consent', :as => :consent_user
  match '/users/unauthorized' => 'users#unauthorized', :as => :unauthorized_user
  match '/users/created/:id' => 'users#created', :as => :created_user
  match '/users/show_log' => 'users#show_log', :as => :show_log_user
  match '/users/:id/withdraw' => 'users#withdraw', :as => :withdraw_user
  match '/users/:id/withdraw_confirm' => 'users#withdraw_confirm', :as => :withdraw_confirm_user
  match '/users/:switch_to_id/switch_to' => 'users#switch_to', :via => [:post], :as => :switch_to_user
  match '/drb/userlog/:user_id' => 'drb#userlog', :as => :userlog_drb
  match '/user/:id/study/:study_id' => 'users#edit_study', :as => :user_edit_study, :via => :get
  match '/user/:id/study/:study_id' => 'users#update_study', :as => :user_update_study, :via => :post
  match '/users/resend_signup_notification_form' => 'users#resend_signup_notification_form', :as => :resend_signup_notification_form
  match '/users/resend_signup_notification/:id' => 'users#resend_signup_notification', :as => :resend_signup_notification_user
  match '/users/create_researcher', :as => :create_researcher, :via => :post
  match '/users/participant_survey' => 'users#participant_survey'
  resources :shipping_addresses
  match '/user/shipping_address' => 'users#shipping_address', :as => 'user_shipping_address'
  resources :users

  resource :session
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/signup' => 'users#new', :as => :signup
  match '/researcher_signup' => 'users#new_researcher', :as => :researcher_signup
  match '/signup_researcher' => 'users#new_researcher', :as => :researcher_signup
  match '/register' => 'users#create', :as => :register
  match '/activate/:code' => 'users#activate', :as => :activate
  resource :password
  resources :accepted_invites

  resources :content_areas do
    resources :exams do
      resources :exam_questions do
        member do
          post :answer
        end
      end
    end
    match 'exams/:id/start' => 'exams#start', :via => [:get, :post], :as => 'start_exam'
    match 'exams/:id/retake' => 'exams#retake', :via => [:get, :post], :as => 'retake_exam'
  end

  namespace :screening_surveys do
      resource :residency
      resource :family
      resource :privacy
  end

  resource :screening_surveys
  match '/screening_survey_results' => 'screening_surveys#results', :as => :screening_survey_results
  resources :waitlist_resubmissions
  resource :phr
  resource :consent_review
  resource :screening_submission
  resource :participation_consent
  resource :enrollment_queue
  resource :baseline_trait_collection_notification
  match '/baseline_trait_collection_notifications/done' => 'baseline_trait_collection_notifications#done', :as => :done_baseline_trait_collection_notification
  resource :identity_verification_notification
  match '/identity_verification_notifications/done' => 'identity_verification_notifications#done', :as => :done_identity_verification_notification
  match '/named_proxies/done' => 'named_proxies#done', :as => :done_named_proxy
  resources :named_proxies
  resources :genetic_data
  match '/genetic_data/download/:id' => 'genetic_data#download', :as => :genetic_data_download
  resource :trait_collection
  resource :distinctive_traits_survey
  resource :pledge
  resource :identity_confirmation
  resource :enrollment_application
  resources :eligibility_screening_results
  resources :enrollment_application_results
  resources :mailing_list_subscriptions
  resources :international_participants
  match '/family_relation/confirm/:id' => 'family_relations#confirm', :as => :confirm_family_relation
  match '/family_relation/reject/:id' => 'family_relations#reject', :as => :reject_family_relation
  match '/family_relations/update' => 'family_relations#update', :as => :update_has_family_relations
  resources :family_relations
  match '/safety_questionnaires/require' => 'safety_questionnaires#require', :as => :require_safety_questionnaire
  resources :safety_questionnaires
  match '/admin/safety_questionnaires' => 'admin/safety_questionnaires#index', :as => :admin_safety_questionnaires
  match '/admin/scoreboards' => 'admin/scoreboards#index', :as => :admin_scoreboards
  match '/admin/researchers' => 'admin/researchers#index', :as => :admin_researchers
  match '/admin/users/enroll' => 'admin/users#enroll', :as => :admin_enroll_users
  match '/admin/users/active' => 'admin/users#active', :as => :admin_active_users
  match '/admin/users/activity' => 'admin/users#activity', :as => :admin_activity_users
  match '/admin/users/log' => 'admin/users#log', :as => :admin_log_users
  match '/admin/users/export_log' => 'admin/users#export_log', :as => :admin_export_log_users
  match '/admin/users/ineligible' => 'admin/users#ineligible', :as => :admin_ineligible_users
  match '/admin/users/trios' => 'admin/users#trios', :as => :admin_trios
  match '/admin/users/absolute_pitch_survey_export' => 'admin/users#absolute_pitch_survey_export', :as => :admin_absolute_pitch_survey_export
  match '/admin/users/absolute_pitch_survey_questions' => 'admin/users#absolute_pitch_survey_questions', :as => :admin_absolute_pitch_survey_questions
  match '/admin/users/genetic_data_report' => 'admin/users#genetic_data_report', :as => :admin_genetic_data_report
  match '/admin/users/google_phr_report' => 'admin/users#google_phr_report', :as => :admin_google_phr_report
  match '/admin/users/activate/:id' => 'admin/users#activate', :as => :activate_admin_user
  match '/admin/users/promote/:id' => 'admin/users#promote', :as => :promote_admin_user

  match '/admin/study/approve/:id' => 'admin/study#approve', :as => :approve_admin_study
  match '/admin/study/deny/:id' => 'admin/study#deny', :as => :deny_admin_study

  namespace :admin do
      root :to => 'homes#index'
      resources :users do
        resources :exam_responses
      end
      resources :studies
      resources :bulk_promotions
      resources :bulk_waitlists
      resources :reports
      resources :content_areas do
          resources :exams do
              resources :exam_versions do
                  member do
                    match 'duplicate' => 'exam_versions#duplicate'
                  end
                  resources :exam_questions do
                      resources :answer_options
                  end
              end
          end
      end
      resources :mailing_lists
      resources :invited_emails
      resources :phr_reports
      resources :oauth_services
      resources :removal_requests
  end

  resources :geographic_information
  match '/:controller(/:action(/:id))'
  resource :phrccr
  match '/phrccr/authsub' => 'phrccrs#authsub_update', :as => :authsub_phrccr
  match '/phrccr/review' => 'phrccrs#review', :as => :review_phrccr
  match '/phrccr/unlink_googlehealth' => 'phrccrs#unlink_googlehealth', :as => :unlink_googlehealth
  match '/profile/:hex' => 'profiles#public', :as => :public_profile
  match '/absolute_pitch_surveys/:id' => 'absolute_pitch_survey#index', :as => :absolute_pitch_surveys_section
  match '/absolute_pitch_surveys/save' => 'absolute_pitch_survey#save', :as => :save_absolute_pitch_surveys
  match '/absolute_pitch_surveys/review/:id' => 'absolute_pitch_survey#review', :as => :review_absolute_pitch_surveys
  match '/trait_surveys' => 'trait_survey#index', :as => :trait_surveys
  match '/traitwise' => 'traitwise#index', :as => :trait_surveys
  match '/traitwise/iframe' => 'traitwise#iframe', :as => :trait_survey_iframe

  root :to => 'pages#show', :action => 'home'
end
