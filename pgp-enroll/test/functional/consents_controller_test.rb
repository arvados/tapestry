require 'test_helper'

class ConsentsControllerTest < ActionController::TestCase

  should "route /consent to ConsentsController#show" do
    assert_routing '/consent', :controller => 'consents', :action     => 'show'
  end

  public_context do
    context 'on GET to show' do
      setup do
        get :show
      end

      should_respond_with :redirect
      should_redirect_to 'new_session_url'
    end
  end

  logged_in_user_context do
    context 'on GET to show' do
      setup do
        get :show
      end

      should_respond_with :success
      should_render_template :show
    end
  end

end
