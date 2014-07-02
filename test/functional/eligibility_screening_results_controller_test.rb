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

      should respond_with :success
      should render_template :index
    end

    context 'on GET to index for a user who has been waitlisted' do
      setup do
        Factory(:waitlist, :user => @user, :created_at => 1.hour.ago)
        @waitlist = Factory(:waitlist, :user => @user)
        get :index
      end

      should respond_with :success
      should render_template :index

      should "render a button to allow the user to re-take the screening surveys" do
        assert_select 'form[action=?][method=post]', waitlist_resubmissions_path(:waitlist_id => @waitlist.id) do
          assert_select 'input[type=submit]'
        end
      end
    end
  end
end
