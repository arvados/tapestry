require 'test_helper'

class PledgesControllerTest < ActionController::TestCase
  should route(:get,  '/pledge').to(:controller => 'pledges', :action => 'show')
  should route(:post, '/pledge').to(:controller => 'pledges', :action => 'create')

  context 'with a logged in user' do
    context "on GET to show" do
      setup { get :show }
      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on POST to create" do
      setup { post :create }
      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end
  end

  logged_in_user_context do
    context 'where pledging is an enrollment step' do
      setup do
        Factory :enrollment_step, :keyword => 'pledge'
      end

      context "on GET to show" do
        setup { get :show }

        should respond_with :success
        should render_template :show

        should "render a form to accept a pledge" do
          assert_select 'form[method=?][action=?]', 'post', pledge_path do
            assert_select 'input[name=?]', 'pledge'
          end
        end
      end

      context "on POST to create with a valid pledge" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create, :pledge => '1000'
        end

        should 'increase the step completion count' do
          assert_equal @count+1, EnrollmentStepCompletion.count
        end

        should 'set the user pledge' do
          assert_equal @user.pledge, 1000
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with no pledge" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create, :pledge => '0'
        end

        should 'increase the step completion count' do
          assert_equal @count+1, EnrollmentStepCompletion.count
        end

        should 'set the user pledge' do
          assert_equal @user.pledge, 0
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with an invalid pledge" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create, :pledge => 'ASDF'
        end

        should 'not increase the step completion count' do
          assert_equal @count, EnrollmentStepCompletion.count
        end

        should respond_with :success
        should render_template :show
        should 'show an appropriate alert' do
          assert_select 'div.alert-error', /pledge/i
        end
      end

      context "on POST to create with a negative pledge" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create, :pledge => '-1'
        end

        should 'not increase the step completion count' do
          assert_equal @count, EnrollmentStepCompletion.count
        end

        should respond_with :success
        should render_template :show
        should 'show an appropriate alert' do
          assert_select 'div.alert-error', /pledge/i
        end
      end
    end
  end
end
