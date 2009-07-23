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

      should 'render links to residency survey' do
        assert_select 'a[href=?]', edit_screening_surveys_residency_url
      end

      should 'render links to family survey' do
        assert_select 'a[href=?]', edit_screening_surveys_family_url
      end

      should 'render links to privacy survey' do
        assert_select 'a[href=?]', edit_screening_surveys_privacy_url
      end

      should 'say that each survey is not complete' do
        assert_select 'li', :text => /not complete/i, :count => 3
      end
    end


    context 'where there are completed surveys' do
      setup do
        @residency_survey_response = Factory(:residency_survey_response, :user => @user)
        @family_survey_response    = Factory(:family_survey_response, :user => @user)
      end

      context 'on GET to index' do
        setup { get :index }

        should_assign_to :residency_survey_response, :equals => '@user.residency_survey_response'
        should_assign_to :family_survey_response,    :equals => '@user.family_survey_response'

        should_respond_with :success
        should_render_template :index

        should 'say that one survey is not complete' do
          assert_select 'li', :text => /Not complete/, :count => 1
        end

        should 'say that two surveys are complete' do
          assert_select 'li', :text => /Complete/, :count => 2
        end
      end
    end

    context "a user has completed all screening surveys" do
      setup do
        Factory(:family_survey_response,    :user => @user)
        Factory(:privacy_survey_response,   :user => @user)
        Factory(:residency_survey_response, :user => @user)
      end

      context "on GET to index" do
        setup do
          get :index
        end

        should_redirect_to 'root_path'
        should_set_the_flash_to /completed/i
      end
    end


  end

end
