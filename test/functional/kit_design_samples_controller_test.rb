require 'test_helper'

class KitDesignSamplesControllerTest < ActionController::TestCase
  setup do
    @kit_design_sample = kit_design_samples(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kit_design_samples)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kit_design_sample" do
    assert_difference('KitDesignSample.count') do
      post :create, :kit_design_sample => @kit_design_sample.attributes
    end

    assert_redirected_to kit_design_sample_path(assigns(:kit_design_sample))
  end

  test "should show kit_design_sample" do
    get :show, :id => @kit_design_sample.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @kit_design_sample.to_param
    assert_response :success
  end

  test "should update kit_design_sample" do
    put :update, :id => @kit_design_sample.to_param, :kit_design_sample => @kit_design_sample.attributes
    assert_redirected_to kit_design_sample_path(assigns(:kit_design_sample))
  end

  test "should destroy kit_design_sample" do
    assert_difference('KitDesignSample.count', -1) do
      delete :destroy, :id => @kit_design_sample.to_param
    end

    assert_redirected_to kit_design_samples_path
  end
end
