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

      should_respond_with :success
      should_render_template :show

      should "render a form to upload traits" do
        assert_select 'form[method=?][action=?]', 'post', trait_collection_path
      end
    end

    context "on POST to create" do
      setup { post :create }

      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end
  end
end
