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
    context 'with an existing residency survey response' do
      setup do
        Factory(:residency_survey_response, :user => @user)
      end

      # context 'on GET to new' do
      # end

      # context 'on POST to create' do
      # end

      context 'on GET to edit' do
        setup do
          get :edit
        end

        should_respond_with :success
        should_render_template :edit
        should_assign_to :residency_survey_response
      end

      context 'on PUT to update' do
        setup do
          @attr_hash = {
            :us_resident => false,
            :country => 'France',
            :contact_when_pgp_opens_outside_us => true
          }

          put :update, :residency_survey_response => @attr_hash
        end

        should 'update the residency_survey_response' do
          @updated_response = @user.residency_survey_response.reload
          @attr_hash.each do |key, value|
            assert_equal value, @updated_response.send(key)
          end
        end

        should_respond_with :redirect
        should_set_the_flash_to /success/i
        should_redirect_to 'edit_screening_surveys_residency_path'
      end
    end
  end

end
