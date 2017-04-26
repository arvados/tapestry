require 'test_helper'

class Admin::RemovalRequestsControllerTest < ActionController::TestCase

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on GET to show" do
      setup do
        removal_request = Factory :removal_request
        get :show, :id => removal_request.id
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @removal_request = Factory :removal_request
        put :update, :id => @removal_request.to_param, :removal_request => { :items_to_remove => 'Crazy new items_to_remove' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the items_to_remove' do
        assert_not_equal RemovalRequest.find(@removal_request.to_param)[:items_to_remove], 'Crazy new items_to_remove'
      end
    end

  end

  logged_in_as_admin do

    setup do
      Factory :removal_request
    end

    context "on GET to index" do
      setup do
        get :index
      end

      should respond_with :success
      should render_template :index

    end

    context "on GET to show" do
      setup do
        removal_request = Factory :removal_request, :user => @user
        get :show, :id => removal_request.to_param
      end

      should respond_with :success
      should render_template :show

    end

    context "on PUT to update" do
      setup do
        @next_value = 'Oh yes quite quite'
        @removal_request = Factory :removal_request, :user => @user
        put :update, :id => @removal_request.to_param, :removal_request => { :items_to_remove => @next_value }
      end

      should 'redirect appropriately' do
        assert_redirected_to admin_removal_requests_path
      end

      should 'have updated the items_to_remove' do
        assert_equal assigns[:removal_request][:items_to_remove], @next_value
        assert_equal RemovalRequest.find(@removal_request)[:items_to_remove], @next_value
      end
    end

  end

end
