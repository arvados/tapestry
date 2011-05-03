PgpEnroll::Application.routes.draw do
  resources :pages
  match '/' => 'pages#show', :id => 'home'
  match '/enrolled' => 'pages#show', :as => :enrolled, :id => 'enrolled'
  match '/users/new2' => 'users#new2', :as => :new2_user
  match '/users/accept_enrollment' => 'users#accept_enrollment', :as => :accept_enrollment_user
  match '/users/tos' => 'users#tos', :as => :tos_user
  match '/users/accept_tos' => 'users#accept_tos', :as => :accept_tos_user
  match '/users/consent' => 'users#consent', :as => :consent_user
  match '/users/unauthorized' => 'users#unauthorized', :as => :unauthorized_user
  match '/users/created/:id' => 'users#created', :as => :created_user
  match '/users/show_log' => 'users#show_log', :as => :show_log_user
  match '/drb/userlog/:user_id' => 'drb#userlog', :as => :userlog_drb
  match '/users/resend_signup_notification_form' => 'users#resend_signup_notification_form', :as => :resend_signup_notification_form
  match '/users/resend_signup_notification/:id' => 'users#resend_signup_notification', :as => :resend_signup_notification_user
  resources :users
  resource :session
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/signup' => 'users#new', :as => :signup
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
  match '/admin/users/enroll' => 'admin/users#enroll', :as => :admin_enroll_users
  match '/admin/users/active' => 'admin/users#active', :as => :admin_active_users
  match '/admin/users/activity' => 'admin/users#activity', :as => :admin_activity_users
  match '/admin/users/ineligible' => 'admin/users#ineligible', :as => :admin_ineligible_users
  match '/admin/users/trios' => 'admin/users#trios', :as => :admin_trios
  match '/admin/users/absolute_pitch_survey_export' => 'admin/users#absolute_pitch_survey_export', :as => :admin_absolute_pitch_survey_export
  match '/admin/users/absolute_pitch_survey_questions' => 'admin/users#absolute_pitch_survey_questions', :as => :admin_absolute_pitch_survey_questions
  match '/admin/users/genetic_data_report' => 'admin/users#genetic_data_report', :as => :admin_genetic_data_report
#    match '/' => 'homes#index'
  namespace :admin do
      root :to => 'homes#index'
      resources :users do
    
    
          resources :exam_responses
    end
      resources :bulk_promotions
      resources :bulk_waitlists
      resources :reports
      resources :content_areas do
    
    
          resources :exams do
      
      
              resources :exam_versions do
        
        
                  resources :exam_questions do
          
          
                      resources :answer_options
          end
        end
      end
    end
      resources :mailing_lists
      resources :invited_emails
      resources :phr_reports
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

  root :to => 'pages#show', :action => 'home'
end
