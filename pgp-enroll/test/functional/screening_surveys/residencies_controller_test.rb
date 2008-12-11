require 'test_helper'

class ScreeningSurveys::ResidenciesControllerTest < ActionController::TestCase
  should "route /screening_surveys/residency/edit to ScreeningSurveys::ResidenciesController#edit" do
    assert_routing '/screening_surveys/residency/edit', :controller => 'screening_surveys/residencies',
                                                        :action     => 'edit'
  end

  public_context do
    context 'on GET to edit' do
      setup do
        get :edit
      end

      should_respond_with :redirect
      should_redirect_to 'login_url'
    end
  end

  logged_in_user_context do
    context 'on GET to edit' do
      setup do
        get :edit
      end

      should_respond_with :success
      should_render_template :edit
    end
  end

end
