require 'test_helper'

class ExamsControllerTest < ActionController::TestCase

  logged_in_user_context do

    context 'with several content areas' do

      setup do
        @exam_version = Factory(:exam_version)
        @exam = @exam_version.exam
        @content_area = @exam.content_area

        Factory(:exam_question, :exam_version => @exam_version)

        Exam.any_instance.stubs(:version_for).returns(@exam_version)
        Exam.any_instance.stubs(:version_for!).returns(@exam_version)
      end

      should 'redirect to the parent content_area on GET to index' do
        get :index, :content_area_id => @content_area
        assert_redirected_to content_area_path(@content_area)
      end

      context 'without having taken the exam before' do
        context 'on POST to start' do
          setup do
            @count = @user.exam_responses.count
            post :start, :content_area_id => @content_area, :id => @exam
          end

          should_redirect_to 'content_area_exam_exam_question_url(@content_area, @exam, @exam_version.exam_questions.first)'

          should 'create a new exam response' do
            assert_equal @count+1, @user.exam_responses.count
          end

          should 'assign the current_user to the exam response user' do
            assert_equal @user, ExamResponse.last.user
          end
        end
      end

      context 'with having taken the exam before and gotten 1 of 2 correct' do
        setup do
          @exam_response = Factory(:exam_response, :user => @user, :exam_version => @exam_version)

          ExamVersion.any_instance.stubs(:question_count).returns(2)
          ExamResponse.any_instance.stubs(:response_count).returns(2)
          ExamResponse.any_instance.stubs(:correct_response_count).returns(1)
        end

        context 'on POST to retake' do
          setup do
            @exam_response_count = ExamResponse.count
            @user_exam_response_count = @user.exam_responses.count
            post :retake, :content_area_id => @content_area, :id => @exam
          end

          should_redirect_to 'content_area_exam_exam_question_path(@content_area, @exam, @exam_version.exam_questions.first)'

          should 'create a new exam response' do
            assert_equal @exam_response_count+1, ExamResponse.count
          end

          should 'not create a new exam_response scoped under the user' do
            assert_equal @user_exam_response_count, @user.exam_responses.count
          end
        end
      end
    end
  end

end
