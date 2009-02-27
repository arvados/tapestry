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
    context 'without an existing residency survey response' do
      context 'on GET to edit' do
        setup do
          new_response = ResidencySurveyResponse.new(:user => @user)
          ResidencySurveyResponse.expects(:new).with({:user => @user}).returns(new_response)
          get :edit
        end

        should_respond_with :success
        should_render_template :edit
        should_assign_to :residency_survey_response
      end
    end

    context 'with an existing residency survey response' do
      setup do
        Factory(:residency_survey_response, :user => @user)
      end

      context 'on GET to edit' do
        setup do
          get :edit
        end

        should_respond_with :success
        should_render_template :edit
        should_assign_to :residency_survey_response

        should 'render a form for the residency_survey_response' do
          assert_select 'form[action=?]', screening_surveys_residency_path do
            assert_select 'input[type=text][name=?]', 'residency_survey_response[zip]'
            assert_select 'select[name=?]', 'residency_survey_response[country]'

            %w(us_resident can_travel_to_boston).each do |boolfield|
              assert_select 'input[type=radio][name=?]', "residency_survey_response[#{boolfield}]"
            end
          end
        end
      end

      context "on PUT to update with valid" do
        setup do
          @attr_hash = Factory.attributes_for(:residency_survey_response, :user => @user)
          put :update, :residency_survey_response => @attr_hash
          @updated_response = @user.residency_survey_response.reload
        end

        should 'update the residency_survey_response' do
          @attr_hash.each do |key, value|
            assert_equal value, @updated_response.send(key)
          end
        end

        should_respond_with :redirect
        should_redirect_to 'screening_surveys_path'

        should_set_the_flash_to /continue/i
      end

      context 'on PUT to update with invalid options' do
        setup do
          @invalid_attr_hash = {
             :us_resident => false,
             :country => nil
          }

          put :update, :residency_survey_response => @invalid_attr_hash
        end

        should_respond_with :success
        should_render_template :edit
      end
    end
  end

end
