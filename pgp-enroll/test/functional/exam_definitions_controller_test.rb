require 'test_helper'

class ExamDefinitionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:exam_definitions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_exam_definition
    assert_difference('ExamDefinition.count') do
      post :create, :exam_definition => { }
    end

    assert_redirected_to exam_definition_path(assigns(:exam_definition))
  end

  def test_should_show_exam_definition
    get :show, :id => exam_definitions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => exam_definitions(:one).id
    assert_response :success
  end

  def test_should_update_exam_definition
    put :update, :id => exam_definitions(:one).id, :exam_definition => { }
    assert_redirected_to exam_definition_path(assigns(:exam_definition))
  end

  def test_should_destroy_exam_definition
    assert_difference('ExamDefinition.count', -1) do
      delete :destroy, :id => exam_definitions(:one).id
    end

    assert_redirected_to exam_definitions_path
  end
end
