require 'test_helper'

class GoogleSurveysControllerTest < ActionController::TestCase
  setup do
    @google_survey = google_surveys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:google_surveys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create google_survey" do
    assert_difference('GoogleSurvey.count') do
      post :create, :google_survey => @google_survey.attributes
    end

    assert_redirected_to google_survey_path(assigns(:google_survey))
  end

  test "should show google_survey" do
    get :show, :id => @google_survey.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @google_survey.to_param
    assert_response :success
  end

  test "should update google_survey" do
    put :update, :id => @google_survey.to_param, :google_survey => @google_survey.attributes
    assert_redirected_to google_survey_path(assigns(:google_survey))
  end

  test "should destroy google_survey" do
    assert_difference('GoogleSurvey.count', -1) do
      delete :destroy, :id => @google_survey.to_param
    end

    assert_redirected_to google_surveys_path
  end
end
