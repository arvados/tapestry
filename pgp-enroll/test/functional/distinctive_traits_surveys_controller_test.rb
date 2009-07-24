require 'test_helper'

class DistinctiveTraitsSurveysControllerTest < ActionController::TestCase
  should_route :get,  '/distinctive_traits_survey', :action => 'show'

  context "on GET to show" do
    setup { get :show }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
    context "on GET to show" do
      setup { get :show }

      should_respond_with :success
      should_render_template :show
    end
  end
end
