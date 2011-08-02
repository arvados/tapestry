require 'test_helper'

class RemovalRequestsControllerTest < ActionController::TestCase
  setup do
    @removal_request = removal_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:removal_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create removal_request" do
    assert_difference('RemovalRequest.count') do
      post :create, :removal_request => @removal_request.attributes
    end

    assert_redirected_to removal_request_path(assigns(:removal_request))
  end

  test "should show removal_request" do
    get :show, :id => @removal_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @removal_request.to_param
    assert_response :success
  end

  test "should update removal_request" do
    put :update, :id => @removal_request.to_param, :removal_request => @removal_request.attributes
    assert_redirected_to removal_request_path(assigns(:removal_request))
  end

  test "should destroy removal_request" do
    assert_difference('RemovalRequest.count', -1) do
      delete :destroy, :id => @removal_request.to_param
    end

    assert_redirected_to removal_requests_path
  end
end
