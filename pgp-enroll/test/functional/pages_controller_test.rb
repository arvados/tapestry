require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  include ApplicationHelper

  should 'route / to PagesController#show with an id of home' do
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => 'home' }, '/')
  end

  %w(home logged_out introduction).each do |page|
    context "on GET to /pages/#{page}" do
      setup { get :show, :id => page }

      should_respond_with :success
      should_render_template page
    end
  end

  context 'on GET to /pages/non-existant-page' do
    setup do
      trap_exception { get :show, :id => 'non-existant-page' }
    end

    should_raise_exception ActionController::RoutingError
  end

end
