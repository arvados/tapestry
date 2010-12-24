require 'test_helper'

class GeneticDataControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:genetic_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create genetic_data" do
    assert_difference('GeneticData.count') do
      post :create, :genetic_data => { }
    end

    assert_redirected_to genetic_data_path(assigns(:genetic_data))
  end

  test "should show genetic_data" do
    get :show, :id => genetic_data(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => genetic_data(:one).id
    assert_response :success
  end

  test "should update genetic_data" do
    put :update, :id => genetic_data(:one).id, :genetic_data => { }
    assert_redirected_to genetic_data_path(assigns(:genetic_data))
  end

  test "should destroy genetic_data" do
    assert_difference('GeneticData.count', -1) do
      delete :destroy, :id => genetic_data(:one).id
    end

    assert_redirected_to genetic_data_path
  end
end
