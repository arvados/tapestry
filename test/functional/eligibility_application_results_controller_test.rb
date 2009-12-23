require 'test_helper'

class EligibilityApplicationResultsControllerTest < ActionController::TestCase
  should_route 'get', '/eligibility_application_results', :action => 'index'
  should_route 'post', '/eligibility_application_results', :action => 'create'

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

      should "populate ivars" do
        assert_equal @user.has_sequence, assigns(:has_sequence)
        assert_equal @user.has_sequence_explanation, assigns(:has_sequence_explanation)
        assert_equal @user.family_members_passed_exam, assigns(:family_members_passed_exam)
      end

      should "render a form requesting more information" do
        assert_select 'form[action=?]', eligibility_application_results_path do
          assert_select 'input[type=checkbox][name=?]', 'has_sequence'
          assert_select 'input[type=text][name=?]', 'has_sequence_explanation'
          assert_select 'textarea[name=?]', 'family_members_passed_exam'
        end
      end
    end

    context 'on POST to create with sequence info' do
      setup do
        assert ! @user.has_sequence
        assert @user.has_sequence_explanation.blank?

        post :create, {
          "has_sequence" => "1",
          "has_sequence_explanation" => "explanation"
        }
      end

      should_redirect_to "eligibility_application_results_url"

      should "update the pertinent user info" do
        assert @user.reload.has_sequence
        assert_equal "explanation", @user.reload.has_sequence_explanation
      end

      should_set_the_flash_to /Thank you/
    end

    context 'on POST to create with family_members_passed_exam info' do
      setup do
        assert @user.family_members_passed_exam.blank?
        post :create, {
          "family_members_passed_exam" => "long explanation"
        }
      end

      should_redirect_to "eligibility_application_results_url"

      should "update the pertinent user info" do
        assert_equal "long explanation", @user.reload.family_members_passed_exam
      end

      should_set_the_flash_to /Thank you/
    end
  end
end
