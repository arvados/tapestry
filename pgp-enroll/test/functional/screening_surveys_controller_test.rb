require 'test_helper'

class ScreeningSurveysControllerTest < ActionController::TestCase
  should "route /screening_surveys to ScreeningSurveysController#index" do
    assert_routing '/screening_surveys', :controller => 'screening_surveys',
                                         :action     => 'index'
  end

  public_context do
    context 'on GET to index' do
      setup do
        get :index
      end

      should_respond_with :redirect
      should_redirect_to 'login_url'
    end
  end

  logged_in_user_context do
    context 'on GET to index' do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template :index
    end

    context 'on POST to complete' do
      setup do
        post :complete
      end

      should_respond_with :redirect
      should_redirect_to 'root_url'
      should_change '@user.completed_enrollment_steps.count', :by => 1
    end
  end


end
