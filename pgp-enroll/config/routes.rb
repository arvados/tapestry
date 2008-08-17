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
    content_area.resources :exam_definitions,
                           :controller => 'content_areas/exam_definitions',
                           :member => {
                             :start  => :post,
                             :retake => :post } do |exam_definition|
      exam_definition.resources :exam_questions,
        :controller => 'content_areas/exam_definitions/exam_questions',
        :member => { :answer => :post }
    end
  end

  map.namespace 'admin' do |admin|
    admin.root :controller => 'homes'
    admin.resources :users, :member => { :activate => :put }
    admin.resources :content_areas do |content_area|
      content_area.resources :exam_definitions, :controller => 'content_areas/exam_definitions' do |exam_definition|
        exam_definition.resources :exam_questions do |exam_question|
          exam_question.resources :answer_options
        end
      end
    end
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
