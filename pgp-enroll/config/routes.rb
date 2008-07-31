ActionController::Routing::Routes.draw do |map|
  map.resources :exam_definitions

  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users',    :action => 'create'
  map.signup   '/signup',   :controller => 'users',    :action => 'new'

  map.activate '/activate/:activation_code', :controller => 'users',    :action => 'activate'

  map.resources :users
  map.resource  :session

  # See how all your routes lay out with "rake routes"
  map.root :controller => 'homes'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
