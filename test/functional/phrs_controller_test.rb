require 'test_helper'

class PhrsControllerTest < ActionController::TestCase
  should route(:get,  '/phr').to( :controller => 'phrs', :action => 'show')
  should route(:post, '/phr').to( :controller => 'phrs', :action => 'create')

  context 'without a logged in user' do
    context 'on GET to show' do
      setup { get :show }
      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context 'on POST to create' do
      setup { post :create }
      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end
  end

  logged_in_user_context do

    context 'where phr is an enrollment step' do

      setup do
        Factory :enrollment_step, :keyword => 'phr'
      end

      context "on GET to show" do
        setup { get :show }

        should respond_with :success
        should render_template :show

        should "render a form to acknowledge PHR" do
          assert_select 'form[method=?][action=?]', 'post', phr_path do
            assert_select 'input[type=text][name=?]', 'phr_profile_name'
            assert_select 'input[type=submit]'
          end
        end
      end

      context "on POST to create with a phr_profile_name" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create, :phr_profile_name => "My Profile Name"
        end

        should 'change step completion count' do
          assert_equal @count+1, EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end

        should "update the user phr_profile_name" do
          assert_equal "My Profile Name", @user.reload.phr_profile_name
        end
      end

      context "on POST to create no params" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create
        end

        should respond_with :success
        should render_template :show

        should 'set the flash appropriately' do
          assert_select 'div.alert-error', /phr profile name/i
        end

        should 'not change step completion count' do
          assert_equal @count, EnrollmentStepCompletion.count
        end
      end
    end
  end
end
