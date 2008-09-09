ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'homes'

  map.resources :users
  map.resource  :session
  map.logout   '/logout',         :controller => 'sessions', :action => 'destroy'
  map.login    '/login',          :controller => 'sessions', :action => 'new'
  map.register '/register',       :controller => 'users',    :action => 'create'
  map.signup   '/signup',         :controller => 'users',    :action => 'new'
  map.activate '/activate/:code', :controller => 'users',    :action => 'activate'

  map.resources :content_areas do |content_area|
    content_area.resources :exams,
                           :controller => 'content_areas/exams',
                           :member => { :start => :post, :retake => :post } do |exam|
      exam.resources :exam_questions,
        :controller => 'content_areas/exams/exam_questions',
        :member => { :answer => :post }
    end
  end

  map.namespace 'admin' do |admin|
    admin.root :controller => 'homes'
    admin.resources :users, :member => { :activate => :put }
    admin.resources :content_areas do |content_area|
      content_area.resources :exams, :controller => 'content_areas/exams' do |exam|
        exam.resources :exam_versions, :member => { :clone => :post } do |exam_version|
          exam_version.resources :exam_questions,
                                 :controller => 'content_areas/exam_versions/exam_questions' do |exam_question|
            exam_question.resources :answer_options,
                                    :controller => 'content_areas/exam_versions/exam_questions/answer_options'
          end
        end
      end
    end
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
