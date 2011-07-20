require 'test_helper'

class Admin::OauthServicesControllerTest < ActionController::TestCase
  setup do
    @admin_oauth_service = admin_oauth_services(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_oauth_services)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_oauth_service" do
    assert_difference('Admin::OauthService.count') do
      post :create, :admin_oauth_service => @admin_oauth_service.attributes
    end

    assert_redirected_to admin_oauth_service_path(assigns(:admin_oauth_service))
  end

  test "should show admin_oauth_service" do
    get :show, :id => @admin_oauth_service.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @admin_oauth_service.to_param
    assert_response :success
  end

  test "should update admin_oauth_service" do
    put :update, :id => @admin_oauth_service.to_param, :admin_oauth_service => @admin_oauth_service.attributes
    assert_redirected_to admin_oauth_service_path(assigns(:admin_oauth_service))
  end

  test "should destroy admin_oauth_service" do
    assert_difference('Admin::OauthService.count', -1) do
      delete :destroy, :id => @admin_oauth_service.to_param
    end

    assert_redirected_to admin_oauth_services_path
  end
end
