require 'test_helper'

class DeviceTypesControllerTest < ActionController::TestCase
  setup do
    @device_type = device_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_type" do
    assert_difference('DeviceType.count') do
      post :create, :device_type => @device_type.attributes
    end

    assert_redirected_to device_type_path(assigns(:device_type))
  end

  test "should show device_type" do
    get :show, :id => @device_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @device_type.to_param
    assert_response :success
  end

  test "should update device_type" do
    put :update, :id => @device_type.to_param, :device_type => @device_type.attributes
    assert_redirected_to device_type_path(assigns(:device_type))
  end

  test "should destroy device_type" do
    assert_difference('DeviceType.count', -1) do
      delete :destroy, :id => @device_type.to_param
    end

    assert_redirected_to device_types_path
  end
end
