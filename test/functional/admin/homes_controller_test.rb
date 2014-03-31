require 'test_helper'

class Admin::HomesControllerTest < ActionController::TestCase

  logged_in_user_context do

    should 'not allow non-admin access to the admin/homes controller' do
      get :index
      assert_response :redirect
      assert_redirected_to login_url
    end
  end

  logged_in_as_admin do

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
        assert_select 'div.main>ul>li', /Mailing lists/
      end
    end
  end
end

