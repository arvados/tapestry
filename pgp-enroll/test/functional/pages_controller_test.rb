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

    should "render a form that POSTs to /accepted_invites#create" do
      assert_select 'form[method=post][action=?]', accepted_invites_path do
        assert_select 'input[type=text][name=?]', 'email'
        assert_select 'input[type=password][name=?]', 'code'
        assert_select 'input[type=submit]'
      end
    end
  end

  logged_in_user_context do
    context 'on GET to /pages/home' do
      setup do
        @enrollment_steps = [Factory(:enrollment_step)]
        EnrollmentStep.expects(:ordered).at_least_once.returns(EnrollmentStep)
        EnrollmentStep.expects(:for_phase).at_least_once.with('screening').returns(@enrollment_steps)
        get :show, :id => 'home'
      end

      should "assign enrollment_steps for the correct phase" do
        assert_equal @enrollment_steps, assigns(:steps)
      end

      should "not render a form to accept an invite" do
        assert_select 'form[method=post][action=?]', accepted_invites_path, :count => 0
      end
    end
  end

end
