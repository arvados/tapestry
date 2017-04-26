require 'test_helper'

class TraitCollectionsControllerTest < ActionController::TestCase
  should route(:get,  '/trait_collection').to(:controller => 'trait_collections', :action => 'show')
  should route(:post, '/trait_collection').to(:controller => 'trait_collections', :action => 'create')

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

  logged_in_enrolled_user_context do
    context 'where trait_collection is an enrollment step' do

      setup do
        Factory :enrollment_step, :keyword => 'trait_collection'
      end

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
          @count = EnrollmentStepCompletion.count
          BaselineTraitsSurvey.any_instance.stubs(:save).returns(true)
          post :create
        end

        should 'increase step completion count' do
          assert_equal @count+1, EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with invalid traits" do
        setup do
          @count = EnrollmentStepCompletion.count
          BaselineTraitsSurvey.any_instance.stubs(:save).returns(false)
          post :create
        end

        should 'not increase step completion count' do
          assert_equal @count, EnrollmentStepCompletion.count
        end

        should render_template :show
        should assign_to "baseline_traits_survey"
      end
    end
  end
end
