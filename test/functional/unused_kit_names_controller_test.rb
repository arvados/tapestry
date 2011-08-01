require 'test_helper'

class UnusedKitNamesControllerTest < ActionController::TestCase
  setup do
    @unused_kit_name = unused_kit_names(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unused_kit_names)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unused_kit_name" do
    assert_difference('UnusedKitName.count') do
      post :create, :unused_kit_name => @unused_kit_name.attributes
    end

    assert_redirected_to unused_kit_name_path(assigns(:unused_kit_name))
  end

  test "should show unused_kit_name" do
    get :show, :id => @unused_kit_name.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @unused_kit_name.to_param
    assert_response :success
  end

  test "should update unused_kit_name" do
    put :update, :id => @unused_kit_name.to_param, :unused_kit_name => @unused_kit_name.attributes
    assert_redirected_to unused_kit_name_path(assigns(:unused_kit_name))
  end

  test "should destroy unused_kit_name" do
    assert_difference('UnusedKitName.count', -1) do
      delete :destroy, :id => @unused_kit_name.to_param
    end

    assert_redirected_to unused_kit_names_path
  end
end
