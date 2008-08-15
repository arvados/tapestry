require 'test_helper'

class ContentAreas::ExamDefinitions::ExamQuestionsControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user

      @exam_question = Factory :multiple_choice_exam_question
      @exam_definition = @exam_question.exam_definition
      @content_area = @exam_definition.content_area
      3.times { Factory :answer_option, :exam_question => @exam_question }
    end

    context 'with an exam started' do
      setup do
        @exam_reponse = Factory(:exam_response, :user => @user, :exam_definition => @exam_definition)
      end

      context 'on GET to show' do
        setup do
          get :show,
              :content_area_id => @content_area.id,
              :exam_definition_id => @exam_definition.id,
              :id => @exam_question
          assert_response :success
          assert_template 'show'
        end

        should 'assign to exam_question, exam_definition, and content_area' do
          assert_equal @exam_question, assigns(:exam_question)
        end
      end
    end
  end
end
