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

  context 'on GET to /pages/home for a not-logged-in user' do
    setup do
      get :show, :id => 'home'
    end

    should "render a form that POSTs to /session" do
      assert_select 'form[method=post][action=?]', session_path do
        assert_select 'input[type=text][name=?]', 'email'
        assert_select 'input[type=password][name=?]', 'password'
        assert_select 'input[type=submit]'
      end
    end

    should "not show the 'Did you know?' box" do
      assert_no_match /did you know/i, @response.body
    end
  end

  logged_in_user_context do
    context 'on GET to /pages/home' do
      setup do
        get :show, :id => 'home'
      end

      should "assign enrollment_steps" do
        assert_equal EnrollmentStep.ordered, assigns(:steps)
      end

      should "not render a form to accept an invite" do
        assert_select 'form[method=post][action=?]', accepted_invites_path, :count => 0
      end

      should "show the 'Did you know?' box" do
        assert_match /did you know/i, @response.body
      end
    end
  end

end
