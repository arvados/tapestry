require 'test_helper'

class Admin::ExamsControllerTest < ActionController::TestCase
  context 'when logged in as an admin, with exam definitions' do
    setup do
      @user = Factory :admin_user
      login_as @user
      @exam_version = Factory :exam_version
      @content_area = @exam_version.content_area
    end

    should "get index" do
      get :index, :content_area_id => @content_area
      assert_response :success
      assert_not_nil assigns(:exam_versions)
    end

    should "get new" do
      get :new, :content_area_id => @content_area
      assert_response :success
    end

    should "create exam definition" do
      assert_difference('ExamVersion.count') do
        exam_version_hash = Factory.attributes_for(:exam_version)
        exam_version_hash[:content_area_id] = Factory(:content_area).id
        post :create, :content_area_id => @content_area, :exam_version => exam_version_hash
      end

      assert_redirected_to admin_content_area_exam_versions_path(@content_area)
    end

    should "show exam definition" do
      get :show, :content_area_id => @content_area, :id => @exam_version.id
      assert_response :success
    end

    should "get edit" do
      get :edit, :content_area_id => @content_area, :id => @exam_version.id
      assert_response :success
    end

    should "update exam definition" do
      put :update, :content_area_id => @content_area, :id => @exam_version.id, :exam_version => { }
      assert_redirected_to admin_content_area_exam_version_path(@content_area, assigns(:exam_version))
    end

    should "destroy exam definition" do
      assert_difference('ExamVersion.count', -1) do
        delete :destroy, :content_area_id => @content_area, :id => @exam_version.id
      end

      assert_redirected_to :action => 'index'
    end
  end
end
