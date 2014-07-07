require 'test_helper'

class DistinctiveTraitsSurveysControllerTest < ActionController::TestCase
  should route( :get, '/distinctive_traits_survey' ).to( :action => 'show' )

  context "on GET to show when not a logged in user" do
    setup { get :show }
    should "redirect appropriately" do
      assert_redirected_to login_path
    end
  end

  logged_in_user_context do
    context "on GET to show when logged in but not enrolled" do
      setup { get :show }

      should 'redirect appropriately' do
        assert_redirected_to unauthorized_user_path
      end
    end
  end

  logged_in_enrolled_user_context do
    context "on GET to show with no existing traits" do
      setup { get :show }

      should respond_with :success
      should render_template :show

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

      should respond_with :success
      should render_template :show

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
      end

      should_eventually "find the existing trait with the rating we set (still baffled why this doesn't work)" do
        assert_select 'select[name=?]', 'traits[][rating]' do
          assert_select 'option[selected=?][value=?]', 'selected', '5'
        end
      end
    end

    context 'where distinctive_traits_survey is an enrollment step' do

      setup do
        Factory :enrollment_step, :keyword => 'distinctive_traits_survey'
      end

      context "on POST to create with no traits" do
        setup do
          @count = EnrollmentStepCompletion.count
          post :create
        end

        should "not create any traits" do
          @user.reload
          assert_equal 0, @user.distinctive_traits.count
        end

        should set_the_flash.to /No distinctive traits/

        should 'increase EnrollmentStepCompletion count by 1' do
          assert_equal (@count + 1), EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with several traits" do
        setup do
          @count = EnrollmentStepCompletion.count
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

        should set_the_flash.to /distinctive traits/

        should 'increase EnrollmentStepCompletion count by 1' do
          assert_equal (@count + 1), EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with several traits and some existing traits" do
        setup do
          @count = EnrollmentStepCompletion.count
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

        should set_the_flash.to /distinctive traits/

        should 'increase EnrollmentStepCompletion count by 1' do
          assert_equal (@count + 1), EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end

      context "on POST to create with some traits filled in, and some left blank" do
        setup do
          @count = EnrollmentStepCompletion.count
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

        should set_the_flash.to /distinctive traits/

        should 'increase EnrollmentStepCompletion count by 1' do
          assert_equal (@count + 1), EnrollmentStepCompletion.count
        end

        should 'redirect appropriately' do
          assert_redirected_to root_path
        end
      end
    end
  end
end
