require 'test_helper'

class PledgesControllerTest < ActionController::TestCase
  should_route :get,  '/pledge', :controller => 'pledges', :action => 'show'
  should_route :post, '/pledge', :controller => 'pledges', :action => 'create'

  context "on GET to show" do
    setup { get :show }
    should_redirect_to "login_url"
  end

  context "on POST to create" do
    setup { post :create }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
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
      setup { post :create, :pledge => '1000' }

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_change '@user.reload.pledge', :to => 1000
      should_redirect_to 'root_path'
    end

    context "on POST to create with no pledge" do
      setup { post :create, :pledge => '0' }

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_change '@user.reload.pledge', :to => 0
      should_redirect_to 'root_path'
    end

    context "on POST to create with an invalid pledge" do
      setup { post :create, :pledge => 'ASDF' }

      should_not_change 'EnrollmentStepCompletion.count'
      should respond_with :success
      should render_template :show
      should set_the_flash.to /pledge/i
    end

    context "on POST to create with a negative pledge" do
      setup { post :create, :pledge => '-1' }

      should_not_change 'EnrollmentStepCompletion.count'
      should respond_with :success
      should render_template :show
      should set_the_flash.to /pledge/i
    end
  end
end
