require 'test_helper'

class ExamQuestionsControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user

      @exam_question = Factory :exam_question
      @exam_version  = @exam_question.exam_version
      @exam          = @exam_version.exam
      @content_area  = @exam.content_area

      Exam.any_instance.expects(:version_for).returns(@exam_version)

      3.times { Factory :answer_option, :exam_question => @exam_question }
    end

    context 'with an exam started' do
      setup do
        @exam_response = Factory(:exam_response, :user => @user, :exam_version => @exam_version)
      end

      context 'on GET to show' do
        setup do
          get :show,
              :content_area_id => @content_area,
              :exam_id         => @exam,
              :id              => @exam_question
          assert_response :success
          assert_template 'show'
        end

        should 'assign to exam_question, exam_version, and content_area' do
          assert_equal @exam_question, assigns(:exam_question)
          assert_equal @exam_version,  assigns(:exam_version)
          assert_equal @content_area,  assigns(:content_area)
        end

        should 'render exam progress' do
          assert_select '.main p', /1 out of 1/
        end
      end
    end
  end
end
