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

    context 'where there are completed but ineligible surveys' do
      setup do
        @residency_survey_response = Factory(:ineligible_residency_survey_response, :user => @user)
        @family_survey_response    = Factory(:ineligible_family_survey_response, :user => @user)
        @privacy_survey_response   = Factory(:ineligible_privacy_survey_response, :user => @user)
      end

      context 'on GET to index' do
        setup { get :index }

        should_assign_to :residency_survey_response, :equals => '@user.residency_survey_response'
        should_assign_to :family_survey_response,    :equals => '@user.family_survey_response'
        should_assign_to :privacy_survey_response,   :equals => '@user.privacy_survey_response'

        should "say that each survey is complete but not eligible" do
          assert_select 'li', :text => /complete.*not eligible/i, :count => 3
        end
      end
    end

    context 'where there are completed and eligible surveys' do
      setup do
        @residency_survey_response = Factory(:residency_survey_response, :user => @user)
        @family_survey_response    = Factory(:family_survey_response, :user => @user)
        @privacy_survey_response   = Factory(:privacy_survey_response, :user => @user)
      end

      context 'on GET to index' do
        setup { get :index }

        should_assign_to :residency_survey_response, :equals => '@user.residency_survey_response'
        should_assign_to :family_survey_response,    :equals => '@user.family_survey_response'
        should_assign_to :privacy_survey_response,   :equals => '@user.privacy_survey_response'

        should "say that each survey is complete and eligible" do
          assert_select 'li', :text => /complete.*eligible/i,     :count => 3
          assert_select 'li', :text => /complete.*not eligible/i, :count => 0
        end
      end
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
