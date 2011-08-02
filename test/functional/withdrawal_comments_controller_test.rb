require 'test_helper'

class WithdrawalCommentsControllerTest < ActionController::TestCase
  setup do
    @withdrawal_comment = withdrawal_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:withdrawal_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create withdrawal_comment" do
    assert_difference('WithdrawalComment.count') do
      post :create, :withdrawal_comment => @withdrawal_comment.attributes
    end

    assert_redirected_to withdrawal_comment_path(assigns(:withdrawal_comment))
  end

  test "should show withdrawal_comment" do
    get :show, :id => @withdrawal_comment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @withdrawal_comment.to_param
    assert_response :success
  end

  test "should update withdrawal_comment" do
    put :update, :id => @withdrawal_comment.to_param, :withdrawal_comment => @withdrawal_comment.attributes
    assert_redirected_to withdrawal_comment_path(assigns(:withdrawal_comment))
  end

  test "should destroy withdrawal_comment" do
    assert_difference('WithdrawalComment.count', -1) do
      delete :destroy, :id => @withdrawal_comment.to_param
    end

    assert_redirected_to withdrawal_comments_path
  end
end
