require 'test_helper'

class Admin::ContentAreasControllerTest < ActionController::TestCase
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

      should_eventually 'show all content_areas' do
        ContentArea.all.each do |area|
          assert_select 'td', area.title
        end
      end
    end
  end
end

