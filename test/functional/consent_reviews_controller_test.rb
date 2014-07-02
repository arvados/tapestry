require 'test_helper'

class ConsentReviewsControllerTest < ActionController::TestCase
  should_route :get, '/consent_review', :controller => 'consent_reviews', :action => 'show'

  context 'on GET to show' do
    setup { get :show }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
    context "on GET to show" do
      setup do
        get :show
      end

      should respond_with :success
      should render_template :show

      should "link to the consent document" do
        assert_select 'a', :text => /download/i
      end

      should "have a form that creates a new consent review" do
        assert_select 'form[method=?][action=?]', 'post', consent_review_path do
          assert_select 'input[type=?][name=?]', 'checkbox', 'consent_review[agreement]'
        end
      end
    end

    context "on POST to create without agreement" do
      setup do
        post :create, :consent_review => { :agreement => "0" }
      end

      should set_the_flash.to /review/i
      should respond_with :success
      should render_template :show
    end

    context "on POST to create with agreement" do
      setup do
        post :create, :consent_review => { :agreement => "1" }
      end

      should_change 'EnrollmentStepCompletion.count'
      should_redirect_to 'root_path'
    end
  end
end
