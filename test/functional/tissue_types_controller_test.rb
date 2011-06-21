require 'test_helper'

class TissueTypesControllerTest < ActionController::TestCase
  setup do
    @tissue_type = tissue_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tissue_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tissue_type" do
    assert_difference('TissueType.count') do
      post :create, :tissue_type => @tissue_type.attributes
    end

    assert_redirected_to tissue_type_path(assigns(:tissue_type))
  end

  test "should show tissue_type" do
    get :show, :id => @tissue_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tissue_type.to_param
    assert_response :success
  end

  test "should update tissue_type" do
    put :update, :id => @tissue_type.to_param, :tissue_type => @tissue_type.attributes
    assert_redirected_to tissue_type_path(assigns(:tissue_type))
  end

  test "should destroy tissue_type" do
    assert_difference('TissueType.count', -1) do
      delete :destroy, :id => @tissue_type.to_param
    end

    assert_redirected_to tissue_types_path
  end
end
