require 'test_helper'

class GoogleSurveysControllerTest < ActionController::TestCase
  setup do
    APP_CONFIG[Section::CONFIG_KEY] |= [Section::GOOGLE_SURVEYS]
  end

  teardown do
    APP_CONFIG[Section::CONFIG_KEY] -= [Section::GOOGLE_SURVEYS]
  end

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should respond_with :success
      should render_template :index
    end

    context "on GET to show" do
      setup do
        user = Factory :user
        survey = Factory :google_survey, :user => user
        get :show, :id => survey.id
      end

      should respond_with :success
      should render_template :show
    end

    context "on GET to new" do
      setup do
        get :new
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on POST to create" do
      setup do
        @count = GoogleSurvey.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the google survey count' do
        assert_equal @count, GoogleSurvey.count
      end
    end

    context "on GET to edit" do
      setup do
        survey = Factory :google_survey
        get :edit, :id => survey.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @survey = Factory :google_survey
        put :update, :id => @survey.to_param, :google_survey => { :description => 'Crazy new description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the description' do
        assert_not_equal GoogleSurvey.find(@survey.to_param)[:description], 'Crazy new description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @survey = Factory :google_survey
        @count = GoogleSurvey.count
        delete :destroy, :id => @survey.to_param
      end

      should 'still be able to find the survey' do
        assert GoogleSurvey.find(@survey)
      end

      should 'leave the survey count as is' do
        assert_equal @count, GoogleSurvey.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_enrolled_user_context do
    context "on participate" do
      setup do
        survey = Factory(:google_survey,
                         :open => true,
                         :form_url => 'https://google.example.com/example-form-url',
                         :userid_populate_entry => 10)
        post :participate, :id => survey.to_param
      end

      should 'redirect' do
        assert_response :redirect
        assert_redirected_to 'https://google.example.com/example-form-url?&entry.1000010=' + assigns(:nonce).nonce
        assert_equal false, assigns(:nonce).nonce.strip.empty?, "nonce is empty"
      end
    end
  end

  logged_in_user_context do
    context "but not a researcher" do
      context "on GET to index" do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index
      end

      context "on GET to show" do
        setup do
          survey = Factory :google_survey
          get :show, :id => survey.to_param
        end

        should respond_with :success
        should render_template :show
      end

      context "on GET to new" do
        setup do
          get :new
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on POST to create" do
        setup do
          @count = GoogleSurvey.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the google survey count' do
          assert_equal @count, GoogleSurvey.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the survey" do
        setup do
          survey = Factory :google_survey, :user => @user, :creator => @user
          get :edit, :id => survey.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the survey" do
        setup do
          @survey = Factory :google_survey, :user => @user, :creator => @user
          put :update, :id => @survey.to_param, :google_survey => { :description => 'Crazy new description' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the description' do
          assert_not_equal GoogleSurvey.find(@survey.to_param)[:description], 'Crazy new description'
        end
      end

    end
  end

  logged_in_researcher_context do

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = GoogleSurvey.count
        post :create
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to google_survey_path(assigns[:google_survey])
      end

      should 'increase the google survey count' do
        assert_equal @count+1, GoogleSurvey.count
      end
    end

    context "on GET to edit" do
      setup do
        survey = Factory :google_survey, :user => @user, :creator => @user
        get :edit, :id => survey.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @survey = Factory :google_survey, :user => @user, :creator => @user
        put :update, :id => @survey.to_param, :google_survey => { :description => 'Crazy new description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to google_survey_path(assigns[:google_survey])
      end

      should 'have updated the description' do
        assert_equal assigns[:google_survey][:description], 'Crazy new description'
        assert_equal GoogleSurvey.find(@survey)[:description], 'Crazy new description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @survey = Factory :google_survey, :user => @user, :creator => @user
        @count = GoogleSurvey.count
        delete :destroy, :id => @survey.to_param
      end

      should 'not be able to find the survey' do
        assert_raise ActiveRecord::RecordNotFound do
          GoogleSurvey.find(@survey)
        end
      end

      should 'reduce the survey count' do
        assert_equal @count-1, GoogleSurvey.count
      end

      should 'redirect appropriately' do
        assert_redirected_to google_surveys_path
      end
    end

  end

end
