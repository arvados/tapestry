require 'test_helper'

class KitDesignsControllerTest < ActionController::TestCase
  setup do
    @kit_design = kit_designs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kit_designs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kit_design" do
    assert_difference('KitDesign.count') do
      post :create, :kit_design => @kit_design.attributes
    end

    assert_redirected_to kit_design_path(assigns(:kit_design))
  end

  test "should show kit_design" do
    get :show, :id => @kit_design.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @kit_design.to_param
    assert_response :success
  end

  test "should update kit_design" do
    put :update, :id => @kit_design.to_param, :kit_design => @kit_design.attributes
    assert_redirected_to kit_design_path(assigns(:kit_design))
  end

  test "should destroy kit_design" do
    assert_difference('KitDesign.count', -1) do
      delete :destroy, :id => @kit_design.to_param
    end

    assert_redirected_to kit_designs_path
  end
end
