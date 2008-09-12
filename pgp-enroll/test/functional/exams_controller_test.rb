require 'test_helper'

class ExamsControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user
      3.times do
        @content_area = Factory :content_area
        3.times { Factory :exam_definition, :content_area => @content_area }
      end
    end

    should 'redirect to the parent content_area on GET to index' do
      get :index, :content_area_id => @content_area
      assert_redirected_to content_area_path(@content_area)
    end


    context 'without having taken the exam before' do
      context 'on GET to show' do
        setup do
          get :show, :content_area_id => ContentArea.first, :id => ExamDefinition.first
          assert_response :success
        end

        should 'prompt you to start' do
          assert_select 'a', /Start/
        end

        should 'create an ExamResponse on POST to start' do
          assert_difference '@user.exam_responses.count' do
            post :start, :content_area_id => ContentArea.first, :id => ExamDefinition.first
            assert_response :redirect
          end
        end
      end
    end

    context 'with having taken the exam before' do
      setup do
        @exam_definition = ExamDefinition.first
        @exam_response = Factory(:exam_response, :user => @user, :exam_definition => @exam_definition)
        @exam_definition.exam_questions.each do |exam_question|
          QuestionResponse.create_by_exam_response_id_and_answer_option_id(
            @exam_response,
            exam_question.answer_options.first)
        end
      end

      context 'on GET to show' do
        setup do
          get :show, :content_area_id => ContentArea.first, :id => ExamDefinition.first
          assert_response :success
        end

        should 'prompt you to retake' do
          assert_select 'a', /Retake/
        end

        should 'discard and create an ExamResponse on POST to retake' do
          assert_difference 'ExamResponse.count' do
            assert_equal 1, @user.exam_responses.count
            post :retake, :content_area_id => ContentArea.first, :id => ExamDefinition.first
            assert_equal 1, @user.exam_responses.count
          end
        end
      end
    end
  end
end
