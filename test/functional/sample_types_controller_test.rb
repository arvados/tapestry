require 'test_helper'

class SampleTypesControllerTest < ActionController::TestCase
  setup do
    @sample_type = sample_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sample_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sample_type" do
    assert_difference('SampleType.count') do
      post :create, :sample_type => @sample_type.attributes
    end

    assert_redirected_to sample_type_path(assigns(:sample_type))
  end

  test "should show sample_type" do
    get :show, :id => @sample_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sample_type.to_param
    assert_response :success
  end

  test "should update sample_type" do
    put :update, :id => @sample_type.to_param, :sample_type => @sample_type.attributes
    assert_redirected_to sample_type_path(assigns(:sample_type))
  end

  test "should destroy sample_type" do
    assert_difference('SampleType.count', -1) do
      delete :destroy, :id => @sample_type.to_param
    end

    assert_redirected_to sample_types_path
  end
end
