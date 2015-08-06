require 'test_helper'

class ParticipationConsentsControllerTest < ActionController::TestCase
  should route(:get,  '/participation_consent').to(:controller => 'participation_consents', :action => 'show')
  should route(:post, '/participation_consent').to(:controller => 'participation_consents', :action => 'create')

  context "on GET to show" do
    setup { get :show }
    should 'redirect accordingly' do
      assert_redirected_to login_path
    end
  end

  context "on POST to create" do
    setup { post :create }
    should 'redirect accordingly' do
      assert_redirected_to login_path
    end
  end

  logged_in_user_context do
    context "on GET to show" do
      setup { get :show }

      should respond_with :success
      should render_template :show

      should "render a form to create a participation consent" do
      end

      should "render form elements for the informed_consent_response" do
        assert_select 'form[method=?][action=?]', 'post', participation_consent_path do
          assert_select 'input[type=radio][name=?][value=0]', "informed_consent_response[recontact]", :count => 1
          assert_select 'input[type=radio][name=?][value=1]', "informed_consent_response[recontact]", :count => 1
          [InformedConsentResponse::TWIN_NO,
           InformedConsentResponse::TWIN_YES,
           InformedConsentResponse::TWIN_UNSURE].each do |v|
            assert_select 'input[type=radio][name=?][value=?]', "informed_consent_response[twin]", v, :count => 1
          end
        end
      end
    end

    context "on POST to create with mismatched confirmation information" do
      setup do
        @count = EnrollmentStepCompletion.count
        post :create, {
          :participation_consent => {
            :name  => 'mismatched-name',
            :email => 'mismatched-email'
          },
          :informed_consent_response => {
            :twin => '',
            :recontact => ''
          } }
      end

      should 'not change the step completion count' do
        assert_equal @count, EnrollmentStepCompletion.count
      end

      should respond_with :success
      should render_template :show

      should "render error messages about the questionnaire" do
        assert_select 'body', /signature must match/i
      end
    end

    context "on POST to create with matched confirmation information but no answers to the questionnaire" do
      setup do
        @count = EnrollmentStepCompletion.count
        post :create, {
          :participation_consent => {
            :name  => @user.full_name,
            :email => @user.email,
          },
          :informed_consent_response => {
            :twin => '',
            :recontact => ''
          } }
      end

      should 'not change the step completion count' do
        assert_equal @count, EnrollmentStepCompletion.count
      end

      should respond_with :success
      should render_template :show

      should "render error messages about the questionnaire" do
        assert_select 'body', /please indicate whether you have an identical twin/i
        assert_select 'body', /Please indicate whether you are willing to be recontacted/i
      end
    end

    context "on POST to create with matched confirmation information and answers to the questionnaire" do
      setup do
        @count = EnrollmentStepCompletion.count
        post :create, {
          :participation_consent => {
            :name  => @user.full_name,
            :email => @user.email,
          },
          :informed_consent_response => {
            :twin => '1',
            :recontact => '1'
          } }
      end

      should 'increase step completion count by 1' do
        assert_equal @count+1, EnrollmentStepCompletion.count
      end

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end

      should "set the user_id on the informed_consent_response" do
        assert_equal @user, InformedConsentResponse.last.user
      end
    end
  end

  logged_in_enrolled_user_context do
    context "on GET to show" do
      setup { get :show }
      should_respond_with :success
      should_render_template :show

      should "render form elements with defaults from latest informed_consent_response" do
        assert_select 'form[method=?][action=?]', 'post', participation_consent_path do
          assert_select "input[type=radio][name='informed_consent_response[recontact]'][value=0]:not([checked])", :count => 1
          assert_select "input[type=radio][name='informed_consent_response[recontact]'][value=1][checked]", :count => 1
          assert_select "input[type=radio][name='informed_consent_response[twin]'][value=?]:not([checked])", InformedConsentResponse::TWIN_NO, :count => 1
          assert_select "input[type=radio][name='informed_consent_response[twin]'][value=?]:not([checked])", InformedConsentResponse::TWIN_YES, :count => 1
          assert_select "input[type=radio][name='informed_consent_response[twin]'][value=?][checked]", InformedConsentResponse::TWIN_UNSURE, :count => 1
        end
      end
    end
  end
end
