require 'test_helper'

class PhrsControllerTest < ActionController::TestCase
  should_route :get,  '/phr', :controller => 'phrs', :action => 'show'
  should_route :post, '/phr', :controller => 'phrs', :action => 'create'

  # context "on GET to show" do
  #   setup { get :show }
  #   should_redirect_to "login_url"
  # end

  # context "on POST to create" do
  #   setup { post :create }
  #   should_redirect_to "login_url"
  # end

  logged_in_user_context do
    context "on GET to show" do
      setup { get :show }

      should_respond_with :success
      should_render_template :show

      should "render a form to acknowledge PHR" do
        assert_select 'form[method=?][action=?]', 'post', phr_path do
          assert_select 'input[type=text][name=?]', 'phr_profile_name'
          assert_select 'input[type=submit]'
        end
      end
    end

    context "on POST to create with a phr_profile_name" do
      setup do
        post :create, :phr_profile_name => "My Profile Name"
      end

      should_change "EnrollmentStepCompletion.count", :by => 1
      should_redirect_to "root_path"

      should "update the user phr_profile_name" do
        assert_equal "My Profile Name", @user.reload.phr_profile_name
      end
    end

    context "on POST to create no params" do
      setup do
        post :create
      end

      should_respond_with :success
      should_render_template :show
      should_set_the_flash_to /phr profile name/i
      should_not_change "EnrollmentStepCompletion.count"
    end
  end
end
