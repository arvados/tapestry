ActionController::Routing::Routes.draw do |map|
  map.resources :pages
  map.root :controller => 'pages', :action => 'show', :id => 'home'

  map.new2_user '/users/new2',    :controller => 'users',    :action => 'new2'
  map.resources :users
  map.resource  :session
  map.login    '/login',          :controller => 'sessions', :action => 'new'
  map.logout   '/logout',         :controller => 'sessions', :action => 'destroy'
  map.signup   '/signup',         :controller => 'users',    :action => 'new'
  map.register '/register',       :controller => 'users',    :action => 'create'
  map.activate '/activate/:code', :controller => 'users',    :action => 'activate'

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
  map.resource :consent_review
  map.resource :screening_submission
  map.resource :participation_consent
  map.resource :trait_collection
  map.resource :pledge

  map.namespace 'admin' do |admin|
    admin.root :controller => 'homes'
    admin.resources :users, :member => { :activate => :put } do |user|
      user.resources :exam_responses
    end
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
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
