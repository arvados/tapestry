require 'test_helper'

class DistinctiveTraitsSurveysControllerTest < ActionController::TestCase
  should_route :get,  '/distinctive_traits_survey', :action => 'show'

  context "on GET to show" do
    setup { get :show }
    should_redirect_to "login_url"
  end

  logged_in_user_context do
    context "on GET to show with no existing traits" do
      setup { get :show }

      should_respond_with :success
      should_render_template :show

      should "render a button to add a new trait" do
        assert_select 'form[method=post][action=?]', distinctive_traits_survey_path do
          assert_select 'input[type=button][value=?]', 'Add another trait'
          assert_select 'input[type=submit][value=?]', 'I am finished entering traits. Submit my list of traits.'
        end
      end

      should "render the form for entering a new trait" do
        assert_select 'input[type=text][name=?]', 'traits[][name]'
        assert_select 'select[name=?]',           'traits[][rating]'
      end
    end

    context "on GET to show with some existing traits" do
      setup do
        Factory(:distinctive_trait, :user => @user, :rating => 5, :name => "Swimming")
        get :show
      end

      should_respond_with :success
      should_render_template :show

      should "render a button to add a new trait" do
        assert_select 'form[method=post][action=?]', distinctive_traits_survey_path do
          assert_select 'input[type=button][value=?]', 'Add another trait'
          assert_select 'input[type=submit][value=?]', 'I am finished entering traits. Submit my list of traits.'
        end
      end

      should "render the form for entering a new trait" do
        assert_select 'input[type=text][name=?]', 'traits[][name]'
        assert_select 'select[name=?]',           'traits[][rating]'
      end

      should "render the form for an existing trait" do
        assert_select 'input[type=text][name=?][value=?]', 'traits[][name]', 'Swimming'
        assert_select 'select[name=?]',           'traits[][rating]' do
          assert_select 'option[selected=selected][value=5]'
        end
      end
    end

    context "on POST to create with no traits" do
      setup do
        post :create
      end

      should "not create any traits" do
        @user.reload
        assert_equal 0, @user.distinctive_traits.count
      end

      should_set_the_flash_to /No distinctive traits/
      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end

    context "on POST to create with several traits" do
      setup do
        post :create, :traits => [
          { :name => "Swimming", :rating => "1" },
          { :name => "Running",  :rating => "5" }
        ]
      end

      should "create those traits" do
        @user.reload
        assert_equal 2,          @user.distinctive_traits.count
        assert_equal "Swimming", @user.distinctive_traits.first.name
        assert_equal 1,          @user.distinctive_traits.first.rating
        assert_equal "Running",  @user.distinctive_traits.second.name
        assert_equal 5,          @user.distinctive_traits.second.rating
      end

      should_set_the_flash_to /distinctive traits/
      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end

    context "on POST to create with several traits and some existing traits" do
      setup do
        Factory(:distinctive_trait, :user => @user, :rating => 5, :name => "Swimming")
        post :create, :traits => [
          { :name => "Swimming", :rating => "1" },
          { :name => "Running",  :rating => "5" }
        ]
      end

      should "create only the new traits" do
        @user.reload
        assert_equal 2,          @user.distinctive_traits.count
        assert_equal "Swimming", @user.distinctive_traits.first.name
        assert_equal 1,          @user.distinctive_traits.first.rating
        assert_equal "Running",  @user.distinctive_traits.second.name
        assert_equal 5,          @user.distinctive_traits.second.rating
      end

      should_set_the_flash_to /distinctive traits/
      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end

    context "on POST to create with some traits filled in, and some left blank" do
      setup do
        post :create, :traits => [
          { :name => "Swimming", :rating => "1" },
          { :name => "",  :rating => "5" }
        ]
      end

      should "only create traits which were not left blank" do
        @user.reload
        assert_equal 1,          @user.distinctive_traits.count
        assert_equal "Swimming", @user.distinctive_traits.first.name
        assert_equal 1,          @user.distinctive_traits.first.rating
      end

      should_set_the_flash_to /distinctive traits/
      should_change 'EnrollmentStepCompletion.count', :by => 1
      should_redirect_to 'root_path'
    end
  end
end
