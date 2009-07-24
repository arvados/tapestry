require 'test_helper'

class EligibilityScreeningResultsControllerTest < ActionController::TestCase
  should_route 'GET', 'eligibility_screening_results', :action => 'index'

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
    end

    context 'on GET to index for a user who has been waitlisted' do
      setup do
        Factory(:waitlist, :user => @user)
        get :index
      end

      should_respond_with :success
      should_render_template :index

      should "render a button to allow the user to re-take the screening surveys" do
        assert_select 'form[action=?][method=post]', screening_submission_path do
          assert_select 'input[type=hidden][name=_method][value=delete]'
          assert_select 'input[type=submit]'
        end
      end
    end
  end
end
