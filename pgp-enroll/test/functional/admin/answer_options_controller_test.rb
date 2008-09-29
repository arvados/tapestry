require 'test_helper'

class Admin::AnswerOptionsControllerTest < ActionController::TestCase

  logged_in_as_admin do
    setup do
      @exam_question = Factory(:exam_question)
      @exam_version  = @exam_question.exam_version
      @exam          = @exam_version.exam
      @content_area  = @exam.content_area

      @context_hash = {
       :content_area_id  => @content_area,
       :exam_id          => @exam,
       :exam_version_id  => @exam_version,
       :exam_question_id => @exam_question
      }
    end

    context 'on GET to index' do
      setup { get :index, @context_hash }

      should_respond_with :success
      should_render_template :index
    end

    context 'on GET to new' do
      setup { get :new, @context_hash }

      should_respond_with :success
      should_render_template :new
    end

    context 'on POST to create' do
      setup do
        hash = { :answer => 'test answer' }
        post :create, @context_hash.merge({ :answer_option => hash })
      end

      should_redirect_to 'admin_content_area_exam_exam_version_exam_question_answer_options_url(@content_area, @exam, @exam_version, @exam_question)'
    end

    context 'with an answer option' do
      setup do
        @answer_option = Factory :answer_option, :exam_question => @exam_question
        @context_hash.merge!({
          :id => @answer_option
        })
      end

      context 'on GET to show' do
        setup { get :show, @context_hash }

        should_respond_with :success
        should_render_template :show
      end

      context 'on GET to edit' do
        setup { get :edit, @context_hash }

        should_respond_with :success
        should_render_template :edit
      end

      context 'on PUT to update' do
        setup do
          hash = { :answer => 'test answer' }.stringify_keys
          AnswerOption.any_instance.expects(:update_attributes).with(hash).returns(true)

          put :update, @context_hash.merge({ :answer_option => hash })
        end

        should 'set the flash[:notice] to /success/i' do
          assert flash[:notice] =~ /success/i
        end

        should_redirect_to 'admin_content_area_exam_exam_version_exam_question_answer_options_url(@content_area, @exam, @exam_version, @exam_question)'
      end

      context 'on DELETE to destroy' do
        setup { delete :destroy, @context_hash }

        should_redirect_to 'admin_content_area_exam_exam_version_exam_question_answer_options_url(@content_area, @exam, @exam_version, @exam_question)'
      end
    end
  end

end
