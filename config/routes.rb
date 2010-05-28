ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.root :controller => 'pages', :action => 'show', :id => 'home'

  map.new2_user '/users/new2',    :controller => 'users',    :action => 'new2'
  map.created_user '/users/created/:id',    :controller => 'users',    :action => 'created'
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

  map.namespace :screening_surveys do |screening_surveys|
    screening_surveys.resource :residency, :family, :privacy
  end
  map.resources :screening_surveys, :collection => { :complete => :post } 
  map.resources :waitlist_resubmissions
  map.resource :phr
  map.resource :consent_review
  map.resource :screening_submission
  map.resource :participation_consent
  map.resource :trait_collection
  map.resource :distinctive_traits_survey
  map.resource :pledge
  map.resource :identity_confirmation
  map.resource :enrollment_application
  map.resources :eligibility_screening_results
  map.resources :eligibility_application_results
  map.resources :mailing_list_subscriptions

  map.namespace 'admin' do |admin|
    admin.root :controller => 'homes'
    admin.resources :users, :member => { :activate => :put,
                                         :promote  => :put } do |user|
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
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
