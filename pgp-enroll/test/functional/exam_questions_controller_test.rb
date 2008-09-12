require 'test_helper'

class ExamQuestionsControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user

      @exam_question = Factory :multiple_choice_exam_question
      @exam_version = @exam_question.exam_version
      @content_area = @exam_version.content_area
      3.times { Factory :answer_option, :exam_question => @exam_question }
    end

    context 'with an exam started' do
      setup do
        @exam_reponse = Factory(:exam_response, :user => @user, :exam_version => @exam_version)
      end

      context 'on GET to show' do
        setup do
          get :show,
              :content_area_id => @content_area.id,
              :exam_version_id => @exam_version.id,
              :id => @exam_question
          assert_response :success
          assert_template 'show'
        end

        should 'assign to exam_question, exam_version, and content_area' do
          assert_equal @exam_question, assigns(:exam_question)
          assert_equal @exam_version, assigns(:exam_version)
          assert_equal @content_area, assigns(:content_area)
        end

        should 'render exam progress' do
          assert_select '.main p', /1 out of 1/
        end
      end
    end
  end
end
