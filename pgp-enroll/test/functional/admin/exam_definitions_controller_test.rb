require 'test_helper'

class Admin::ExamDefinitionsControllerTest < ActionController::TestCase
  context 'when logged in as an admin, with exam definitions' do
    setup do
      @user = Factory :admin_user
      login_as @user
      @exam_definition = Factory :exam_definition
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:exam_definitions)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    should "create exam definition" do
      assert_difference('ExamDefinition.count') do
        exam_definition_hash = Factory.attributes_for(:exam_definition)
        exam_definition_hash[:content_area_id] = Factory(:content_area).id
        post :create, :exam_definition => exam_definition_hash
      end

      assert_redirected_to admin_exam_definitions_path
    end

    should "show exam definition" do
      get :show, :id => @exam_definition.id
      assert_response :success
    end

    should "get edit" do
      get :edit, :id => @exam_definition.id
      assert_response :success
    end

    should "update exam definition" do
      put :update, :id => @exam_definition.id, :exam_definition => { }
      assert_redirected_to admin_exam_definition_path(assigns(:exam_definition))
    end

    should "destroy exam definition" do
      assert_difference('ExamDefinition.count', -1) do
        delete :destroy, :id => @exam_definition.id
      end

      assert_redirected_to admin_exam_definitions_path
    end
  end
end
