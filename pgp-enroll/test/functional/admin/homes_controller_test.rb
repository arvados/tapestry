require 'test_helper'

class Admin::HomesControllerTest < ActionController::TestCase
  context 'when logged in as a non-admin' do
    setup do
      @user = Factory(:user)
      @user.activate!
      login_as @user
    end

    should 'not allow access to the admin/homes controller' do
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

      should 'show all admin areas' do
        assert_select 'div.main>ul>li', /Users/
        assert_select 'div.main>ul>li', /Exams/
        assert_select 'div.main>ul>li', /Reports/
        assert_select 'div.main>ul>li', /Invited Email Addresses/
      end
    end
  end
end

