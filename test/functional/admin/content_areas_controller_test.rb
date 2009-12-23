require 'test_helper'

class Admin::ContentAreasControllerTest < ActionController::TestCase
  context 'when logged in as an admin, with content areas' do
    setup do
      @user = Factory :admin_user
      login_as @user
      @content_area = Factory :content_area
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:content_areas)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create content area" do
      assert_difference('ContentArea.count') do
        post :create, :content_area => Factory.attributes_for(:content_area)
      end

      assert_redirected_to admin_content_areas_path
    end

    context 'on GET to show' do
      setup { get :show, :id => @content_area }

      should_redirect_to 'admin_content_area_exams_url(@content_area)'
    end

    should "get edit" do
      get :edit, :id => @content_area.id
      assert_response :success
    end

    should "update content area" do
      put :update, :id => @content_area.id, :content_area => { }
      assert_redirected_to admin_content_areas_path
    end

    should "destroy content area" do
      assert_difference('ContentArea.count', -1) do
        delete :destroy, :id => @content_area.id
      end

      assert_redirected_to admin_content_areas_path
    end
  end
end
