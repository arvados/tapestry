require 'test_helper'

class ParticipationConsentsControllerTest < ActionController::TestCase
  should_route :get,  '/participation_consent', :controller => 'participation_consents', :action => 'show'
  should_route :post, '/participation_consent', :controller => 'participation_consents', :action => 'create'

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

      should_respond_with :success
      should_render_template :show

      should "render a form to create a participation consent" do
        assert_select 'form[method=?][action=?]', 'post', participation_consent_path
      end
    end

    context "on POST to create with mismatched confirmation information" do
      setup do
        post :create, :participation_consent => {
          :name  => 'mismatched-name',
          :email => 'mismatched-email'
        }
      end

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should_set_the_flash_to /name/i
      should_set_the_flash_to /email/i
    end

    context "on POST to create with matched confirmation information" do
      setup do
        post :create, :participation_consent => {
          :name  => @user.full_name,
          :email => @user.email
        }
      end

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end
  end
end
