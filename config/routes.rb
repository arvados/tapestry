ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.root :controller => 'pages', :action => 'show', :id => 'home'
  map.enrolled '/enrolled',    :controller => 'pages',    :action => 'show', :id => 'enrolled'

  map.new2_user '/users/new2',    :controller => 'users',    :action => 'new2'
  map.accept_enrollment_user '/users/accept_enrollment',    :controller => 'users',    :action => 'accept_enrollment'
  map.tos_user '/users/tos',    :controller => 'users',    :action => 'tos'
  map.accept_tos_user '/users/accept_tos',    :controller => 'users',    :action => 'accept_tos'
  map.consent_user '/users/consent',    :controller => 'users',    :action => 'consent'
  map.unauthorized_user '/users/unauthorized',    :controller => 'users',    :action => 'unauthorized'
  map.created_user '/users/created/:id',    :controller => 'users',    :action => 'created'
  map.show_log_user '/users/show_log',    :controller => 'users',    :action => 'show_log'

  map.userlog_drb '/drb/userlog/:user_id',    :controller => 'drb',    :action => 'userlog'

  map.resend_signup_notification_form '/users/resend_signup_notification_form',    :controller => 'users',    :action => 'resend_signup_notification_form'
  map.resend_signup_notification_user '/users/resend_signup_notification/:id',    :controller => 'users',    :action => 'resend_signup_notification'
  map.resources :users
  map.resource  :session
  map.login    '/login',          :controller => 'sessions', :action => 'new'
  map.logout   '/logout',         :controller => 'sessions', :action => 'destroy'
  map.signup   '/signup',         :controller => 'users',    :action => 'new'
  map.register '/register',       :controller => 'users',    :action => 'create'
  map.activate '/activate/:code', :controller => 'users',    :action => 'activate'

  map.resource :password

  map.resources :accepted_invites

  map.resources :content_areas do |content_area|
    # /content_areas/:content_area_id/exams/:id will show _a version of_ that exam;
    # particularly, exam.version_for(current_user)
    content_area.resources :exams, :member => { :start  => :post, :retake => :post } do |exam|
      exam.resources :exam_questions, :member => { :answer => :post }
    end
  end

  # the following is legacy - to be removed when we remove eligibility exam v1 code
  map.namespace :screening_surveys do |screening_surveys|
    screening_surveys.resource :residency, :family, :privacy
  end
  # /legacy
  map.resource :screening_surveys
  map.screening_survey_results '/screening_survey_results',    :controller => 'screening_surveys',    :action => 'results'
  map.resources :waitlist_resubmissions
  map.resource :phr
  map.resource :consent_review
  map.resource :screening_submission
  map.resource :participation_consent
  map.resource :enrollment_queue
  map.resource :baseline_trait_collection_notification
  map.done_baseline_trait_collection_notification '/baseline_trait_collection_notifications/done', :controller => 'baseline_trait_collection_notifications', :action => 'done'
  map.resource :identity_verification_notification
  map.done_identity_verification_notification '/identity_verification_notifications/done', :controller => 'identity_verification_notifications', :action => 'done'
  map.done_named_proxy '/named_proxies/done', :controller => 'named_proxies', :action => 'done'
  map.resources :named_proxies
  map.resources :genetic_data, :singular => :genetic_data_instance
  map.genetic_data_download '/genetic_data/download/:id',    :controller => 'genetic_data',    :action => 'download'
  map.resource :trait_collection
  map.resource :distinctive_traits_survey
  map.resource :pledge
  map.resource :identity_confirmation
  map.resource :enrollment_application
  map.resources :eligibility_screening_results
  map.resources :enrollment_application_results
  map.resources :mailing_list_subscriptions
  map.resources :international_participants
  map.confirm_family_relation '/family_relation/confirm/:id',    :controller => 'family_relations',    :action => 'confirm'
  map.reject_family_relation '/family_relation/confirm/:id',    :controller => 'family_relations',    :action => 'reject'
  map.update_has_family_relations '/family_relations/update', :controller => 'family_relations', :action => 'update'
  map.resources :family_relations
  map.require_safety_questionnaire '/safety_questionnaires/require',    :controller => 'safety_questionnaires',    :action => 'require'
  map.resources :safety_questionnaires

  map.admin_safety_questionnaires '/admin/safety_questionnaires',    :controller => 'admin/safety_questionnaires',    :action => 'index'
  map.admin_enroll_users '/admin/users/enroll',    :controller => 'admin/users',    :action => 'enroll'
  map.admin_active_users '/admin/users/active',    :controller => 'admin/users',    :action => 'active'
  map.admin_activity_users '/admin/users/activity',    :controller => 'admin/users',    :action => 'activity'
  map.admin_ineligible_users '/admin/users/ineligible',    :controller => 'admin/users',    :action => 'ineligible'
  map.admin_trios '/admin/users/trios',    :controller => 'admin/users',    :action => 'trios'
  map.admin_absolute_pitch_survey_export '/admin/users/absolute_pitch_survey_export', :controller => 'admin/users', :action => 'absolute_pitch_survey_export'
  map.admin_absolute_pitch_survey_questions '/admin/users/absolute_pitch_survey_questions', :controller => 'admin/users', :action => 'absolute_pitch_survey_questions'
  map.admin_genetic_data_report '/admin/users/genetic_data_report', :controller => 'admin/users', :action => 'genetic_data_report'
  map.namespace 'admin' do |admin|
    admin.root :controller => 'homes'
    admin.resources :users, :member => { :activate => :put,
    		    	    	       	 :promote  => :put,
					 :ccr => :get,
					 :demote => :put } do |user|
      user.resources :exam_responses
    end
    admin.resources :bulk_promotions
    admin.resources :bulk_waitlists
    admin.resources :reports
    admin.resources :content_areas do |content_area|
      content_area.resources :exams do |exam|
        exam.resources :exam_versions, :member => { :duplicate => :post } do |exam_version|
          exam_version.resources :exam_questions do |exam_question|
            exam_question.resources :answer_options
          end
        end
      end
    end
    admin.resources :mailing_lists
    admin.resources :invited_emails
    admin.resources :phr_reports
  end

  map.resources :geographic_information

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.resource :phrccr
  map.authsub_phrccr '/phrccr/authsub', :controller => 'phrccrs', :action => 'authsub_update'
  map.review_phrccr '/phrccr/review', :controller => 'phrccrs', :action => 'review'
  map.unlink_googlehealth '/phrccr/unlink_googlehealth', :controller => 'phrccrs', :action => 'unlink_googlehealth'

  map.public_profile '/profile/:hex',    :controller => 'profiles',    :action => 'public'

  map.absolute_pitch_surveys_section '/absolute_pitch_surveys/:id', :controller => 'absolute_pitch_survey', :action => 'index'
  map.save_absolute_pitch_surveys '/absolute_pitch_surveys/save', :controller => 'absolute_pitch_survey', :action => 'save'
  map.review_absolute_pitch_surveys '/absolute_pitch_surveys/review/:id', :controller => 'absolute_pitch_survey', :action => 'review'
  map.trait_surveys '/trait_surveys', :controller => 'trait_survey', :action => 'index'
  map.trait_surveys '/traitwise', :controller => 'traitwise', :action => 'index'

end
