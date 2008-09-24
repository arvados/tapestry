require 'test_helper'

class ExamsControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user
      3.times do
        @content_area = Factory :content_area
        3.times do
          exam = Factory(:exam, :content_area => @content_area)
          version = Factory(:exam_version, :exam => exam)
        end
      end
    end

    should 'redirect to the parent content_area on GET to index' do
      get :index, :content_area_id => @content_area
      assert_redirected_to content_area_path(@content_area)
    end


    context 'without having taken the exam before' do
      context 'on GET to show' do
        setup do
          @exam = Exam.first
          get :show, :content_area_id => ContentArea.first, :id => @exam
          assert_response :success
        end

        should 'prompt you to start' do
          assert_select 'a', /Start/
        end

        should 'create an ExamResponse on POST to start' do
          assert_difference '@user.exam_responses.count' do
            post :start, :content_area_id => ContentArea.first, :id => @exam
            assert_response :redirect
          end
        end
      end
    end

    context 'with having taken the exam before' do
      setup do
        @exam = Exam.first

        @exam_version = @exam.versions.first
        @exam.stubs(:version_for).returns(@exam_version)

        @exam_response = Factory(:exam_response, :user => @user, :exam_version => @exam_version)
        @exam_version.exam_questions.each do |exam_question|
          QuestionResponse.create_by_exam_response_id_and_answer_option_id(@exam_response, exam_question.answer_options.first)
        end
      end

      context 'on GET to show' do
        setup do
          get :show, :content_area_id => ContentArea.first, :id => @exam
        end

        should_respond_with :success

        should 'set exam_version to @exam.version_for(@user)' do
          assert_equal assigns(:exam_version), @exam.version_for(@user)
        end

        should 'prompt you to retake' do
          assert_select 'a', /Retake/
        end

        should 'discard and create an ExamResponse on POST to retake' do
          assert_difference 'ExamResponse.count' do
            assert_equal 1, @user.exam_responses.count
            post :retake, :content_area_id => ContentArea.first, :id => @exam
            assert_equal 1, @user.exam_responses.count
          end
        end
      end
    end
  end
end
