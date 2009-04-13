require 'test_helper'

class EligibilityApplicationResultsControllerTest < ActionController::TestCase
  should_route 'GET', 'eligibility_application_results', :action => 'index'

  context "on GET to index" do
    setup { get :index }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
    context 'on GET to index' do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template :index
    end
  end
end
