require 'test_helper'

class WithdrawalCommentsControllerTest < ActionController::TestCase

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on GET to new" do
      setup do
        get :new
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on POST to create" do
      setup do
        @count = WithdrawalComment.count
        post :create
      end

      should_not set_the_flash.to /have been recorded/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the withdrawal_comment count' do
        assert_equal @count, WithdrawalComment.count
      end
    end

    context "on GET to show" do
      setup do
        withdrawal_comment = Factory :withdrawal_comment
        get :show, :id => withdrawal_comment.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do

    context "on GET to index" do
      setup do
        get :index
      end

      should 'redirect appropriately' do
        assert_redirected_to unauthorized_user_path
      end
    end

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = WithdrawalComment.count
        post :create, :withdrawal_comment => Factory.attributes_for(:withdrawal_comment)
      end

      should set_the_flash.to /have been recorded/i

      should 'redirect appropriately' do
        assert_redirected_to withdrawal_comment_path(assigns(:withdrawal_comment))
      end

      should 'increase the withdrawal_comment count' do
        assert_equal @count+1, WithdrawalComment.count
      end
    end

    context "on GET to show" do
      setup do
        withdrawal_comment = Factory(:withdrawal_comment, :user => @user)
        get :show, :id => withdrawal_comment.to_param
      end

      should respond_with :success
      should render_template :show
    end

  end

  logged_in_as_admin do
    context "on GET to index" do
      setup do
        2.times do
          Factory :withdrawal_comment, :user => Factory(:user)
        end
        get :index
      end

      should respond_with :success
      should render_template :index
    end
  end

end
