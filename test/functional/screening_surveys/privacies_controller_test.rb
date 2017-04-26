require 'test_helper'

class ScreeningSurveys::PrivaciesControllerTest < ActionController::TestCase
  should "route /screening_surveys/privacy/edit to ScreeningSurveys::ResidenciesController#edit" do
    assert_routing '/screening_surveys/privacy/edit', :controller => 'screening_surveys/privacies',
                                                      :action     => 'edit'
  end

  public_context do
    context 'on GET to edit' do
      setup do
        get :edit
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end
  end

  logged_in_user_context do
    context 'without an existing privacy survey response' do
      context 'on GET to edit' do
        setup do
          new_response = PrivacySurveyResponse.new(:user => @user)
          PrivacySurveyResponse.expects(:new).with({:user => @user}).returns(new_response)
          get :edit
        end

        should respond_with :success
        should render_template :edit
        should assign_to :privacy_survey_response
      end
    end

    context 'with an existing privacy survey response' do
      setup do
        Factory(:privacy_survey_response, :user => @user)
      end

      context 'on GET to edit' do
        setup do
          get :edit
        end

        should respond_with :success
        should render_template :edit
        should assign_to :privacy_survey_response

        should 'render a form for the privacy_survey_response' do
          assert_select 'form[action=?]', screening_surveys_privacy_path
        end

        should 'render the worrisome_information_comfort_level question' do
          PrivacySurveyResponse::WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS.values.each do |value|
            assert_select 'input[type=radio][name=?][value=?]', 'privacy_survey_response[worrisome_information_comfort_level]', value
          end
        end

        should 'render the information_disclosure_comfort_level question' do
          PrivacySurveyResponse::INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS.values.each do |value|
            assert_select 'input[type=radio][name=?][value=?]', 'privacy_survey_response[information_disclosure_comfort_level]', value
          end
        end

        should 'render the past_genetic_test_participation question' do
          PrivacySurveyResponse::PAST_GENETIC_TEST_PARTICIPATION_OPTIONS.values.each do |value|
            assert_select 'input[type=radio][name=?][value=?]', 'privacy_survey_response[past_genetic_test_participation]', value
          end
        end
      end

      context "on PUT to update with valid options" do
        setup do
          @attr_hash = Factory.attributes_for(:privacy_survey_response, :user => @user)
          put :update, :privacy_survey_response => @attr_hash
          @updated_response = @user.privacy_survey_response.reload
        end

        should 'update the privacy_survey_response' do
          @attr_hash.each do |key, value|
            assert_equal value, @updated_response.send(key)
          end
        end

        should 'redirect appropriately' do
          assert_redirected_to screening_surveys_path
        end

        should set_the_flash.to /continue/i
      end

      context 'on PUT to update with invalid options' do
        setup do
          @invalid_attr_hash = {
             :past_genetic_test_participation => nil
          }

          put :update, :privacy_survey_response => @invalid_attr_hash
        end

        should respond_with :success
        should render_template :edit
      end
    end
  end

end
