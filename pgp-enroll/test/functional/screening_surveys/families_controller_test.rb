require 'test_helper'

class ScreeningSurveys::FamiliesControllerTest < ActionController::TestCase
  should "route /screening_surveys/family/edit to ScreeningSurveys::ResidenciesController#edit" do
    assert_routing '/screening_surveys/family/edit', :controller => 'screening_surveys/families',
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
    context 'without an existing family survey response' do
      context 'on GET to edit' do
        setup do
          new_response = FamilySurveyResponse.new(:user => @user)
          FamilySurveyResponse.expects(:new).with({:user => @user}).returns(new_response)
          get :edit
        end

        should_respond_with :success
        should_render_template :edit
        should_assign_to :family_survey_response
      end
    end

    context 'with an existing family survey response' do
      setup do
        Factory(:family_survey_response, :user => @user)
      end

      context 'on GET to edit' do
        setup do
          get :edit
        end

        should_respond_with :success
        should_render_template :edit
        should_assign_to :family_survey_response

        should 'render a form for the family_survey_response' do
          assert_select 'form[action=?]', screening_surveys_family_path do
            assert_select 'input[type=text][name=?]', "family_survey_response[birth_year]"
            assert_select 'input[type=text][name=?]', "family_survey_response[youngest_child_age]"

            assert_select 'select[name=?]', 'family_survey_response[relatives_interested_in_pgp]' do
              FamilySurveyResponse::RELATIVES_INTERESTED_IN_PGP_VALUES.each do |value|
                assert_select 'option[value=?]', value
              end
            end

            FamilySurveyResponse::MONOZYGOTIC_TWIN_OPTIONS.values.each do |value|
              assert_select 'input[type=radio][name=?][value=?]', 'family_survey_response[monozygotic_twin]', value
            end

            FamilySurveyResponse::CHILD_SITUATION_OPTIONS.values.each do |value|
              assert_select 'input[type=radio][name=?][value=?]', 'family_survey_response[child_situation]', value
            end

          end
        end
      end

      context 'on PUT to update with valid but ineligible options' do
        setup do
          @attr_hash = {
            :birth_year => 1983,
            :relatives_interested_in_pgp => '0',
            # :monozygotic_twin => 'no',
            :monozygotic_twin => 'unwilling',
            :child_situation => 'none'
          }

          put :update, :family_survey_response => @attr_hash

          @updated_response = @user.family_survey_response.reload
        end

        should 'update the family_survey_response' do
          @attr_hash.each do |key, value|
            assert_equal value, @updated_response.send(key)
          end
        end

        should_respond_with :redirect
        should_redirect_to 'screening_surveys_path'

        should "set the flash to the waitlist message" do
          assert_equal flash[:warning], @updated_response.waitlist_message
        end
      end

      context 'on PUT to update with valid and eligible options' do
        setup do
          @attr_hash = {
            :birth_year => 1983,
            :relatives_interested_in_pgp => '0',
            :monozygotic_twin => 'no',
            # :monozygotic_twin => 'unwilling',
            :child_situation => 'none'
          }

          put :update, :family_survey_response => @attr_hash

          @updated_response = @user.family_survey_response.reload
        end

        should 'update the family_survey_response' do
          @attr_hash.each do |key, value|
            assert_equal value, @updated_response.send(key)
          end
        end

        should_respond_with :redirect
        should_redirect_to 'screening_surveys_path'

        should_set_the_flash_to /passed/i
      end

      context 'on PUT to update with invalid options' do
        setup do
          @invalid_attr_hash = {
             :monozygotic_twin => nil,
             :youngest_child_age => nil
          }

          put :update, :family_survey_response => @invalid_attr_hash
        end

        should_respond_with :success
        should_render_template :edit
      end
    end
  end

end
