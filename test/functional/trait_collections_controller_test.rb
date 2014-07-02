require 'test_helper'

class TraitCollectionsControllerTest < ActionController::TestCase
  should_route :get,  '/trait_collection', :controller => 'trait_collections', :action => 'show'
  should_route :post, '/trait_collection', :controller => 'trait_collections', :action => 'create'

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
      should assign_to "baseline_traits_survey"

      should "render a form to upload traits" do
        assert_select 'form[method=?][action=?]', 'post', trait_collection_path
      end
    end

    context "on POST to create with valid traits" do
      setup do
        BaselineTraitsSurvey.any_instance.stubs(:save).returns(true)
        post :create
      end

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end

    context "on POST to create with invalid traits" do
      setup do
        BaselineTraitsSurvey.any_instance.stubs(:save).returns(false)
        post :create
      end

      should_not_change 'EnrollmentStepCompletion.count'
      should render_template :show
      should assign_to "baseline_traits_survey"
    end
  end
end
