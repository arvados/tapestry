require 'test_helper'

class ConsentReviewsControllerTest < ActionController::TestCase
  should route( :get, '/consent_review' ).to( :action => 'show' )

  context 'on GET to show when not logged in' do
    setup { get :show }

    should 'redirect to the correct path' do
      assert_redirected_to login_path
    end

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

      should 'show an appropriate error' do
        assert_select 'div.alert-error', /review/i
      end

      should respond_with :success
      should render_template :show
    end

    context "on POST to create with agreement" do
      setup do
        @count = EnrollmentStepCompletion.count
        post :create, :consent_review => { :agreement => "1" }
      end

      should 'change the EnrollmentStepCompletion count' do
        assert_equal @count+1, EnrollmentStepCompletion.count
      end

      should 'redirect to the correct path' do
        assert_redirected_to root_path
      end

    end
  end
end
