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
      end

      should "render form elements for the informed_consent_response" do
        assert_select 'form[method=?][action=?]', 'post', participation_consent_path do
          %w(twin biopsy recontact).each do |radio_name|
            assert_select 'input[type=radio][name=?]', "informed_consent_response[#{radio_name}]", :count => 2
          end
        end
      end
    end

    context "on POST to create with mismatched confirmation information" do
      setup do
        post :create,
          :participation_consent => {
            :name  => 'mismatched-name',
            :email => 'mismatched-email'
          },
          :informed_consent_response => {
            :twin => '',
            :biopsy => '',
            :recontact => ''
          }
      end

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should_set_the_flash_to /name/i
      should_set_the_flash_to /email/i
    end

    context "on POST to create with matched confirmation information but no answers to the questionnaire" do
      setup do
        post :create,
          :participation_consent => {
            :name  => @user.full_name,
            :email => @user.email,
          },
          :informed_consent_response => {
            :twin => '',
            :biopsy => '',
            :recontact => ''
          }
      end

      should_not_change 'EnrollmentStepCompletion.count'
      should_respond_with :success
      should_render_template :show

      should "render error messages about the questionnaire" do
        assert_match /You must answer the questions within the Consent Form/, @response.body
      end
    end

    context "on POST to create with matched confirmation information and answers to the questionnaire" do
      setup do
        post :create,
          :participation_consent => {
            :name  => @user.full_name,
            :email => @user.email,
          },
          :informed_consent_response => {
          :twin => 'true',
          :biopsy => 'true',
          :recontact => 'true'
        }
      end

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'

      should "set the user_id on the informed_consent_response" do
        assert_equal @user, InformedConsentResponse.last.user
      end
    end

  end
end
