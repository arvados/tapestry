require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  context 'when logged in as a non-admin' do
    setup do
      @user = Factory(:user)
      @user.activate!
      login_as @user
    end

    should 'not allow access to the admin/users controller' do
      get :index
      assert_response :redirect
      assert_redirected_to login_url
    end
  end

  context 'when logged in as an admin' do
    setup do
      @user = Factory(:admin_user)
      @user.activate!
      login_as @user
    end

    context 'on GET to index' do
      setup do
        get :index
        assert_response :success
      end

      should 'show all users' do
        User.all.each do |user|
          assert_select 'td', user.email
        end
      end
    end

    should 'activate user on PUT to #activate' do
      @inactive_user = Factory(:user)
      put :activate, :id => @inactive_user
      @inactive_user.reload
      assert @inactive_user.active?
    end

    should 'delete user on DELETE' do
      @another_user = Factory(:user)
      delete :destroy, :id => @another_user
      assert_raises ActiveRecord::RecordNotFound do
        get :edit, :id => @another_user
      end
    end
  end

end
