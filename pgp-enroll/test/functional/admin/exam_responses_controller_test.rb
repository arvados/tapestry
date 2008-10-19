require 'test_helper'

class Admin::ExamResponsesControllerTest < ActionController::TestCase

  should "route /admin/users/1/exam_responses to Admin::ExamResponsesController#index" do
    assert_routing '/admin/users/1/exam_responses', :controller => 'admin/exam_responses',
                                                    :action     => 'index',
                                                    :user_id    => '1'
  end

  should "route /admin/users/1/exam_responses/show to Admin::ExamResponsesController#show" do
    assert_routing '/admin/users/1/exam_responses/2', :controller => 'admin/exam_responses',
                                                      :action     => 'show',
                                                      :user_id    => '1',
                                                      :id         => '2'
  end

  should_only_allow_admins_on 'get :show'

  logged_in_as_admin do
    context 'with some exam responses' do
      setup do
        @user = Factory(:user)
        @user.activate!
        @exam_responses = []
        5.times { @exam_responses << Factory(:exam_response, :user => @user) }
      end

      context 'on GET to index' do
        setup do
          get :index, :user_id => @user
        end

        should_respond_with :success
        should_render_template :index
        should_assign_to :exam_responses
      end

      context 'on GET to show' do
        setup do
          @exam_response = @exam_responses.first
          get :show, :user_id => @user, :id => @exam_response
        end

        should_respond_with :success
        should_render_template :show

        should_assign_to :content_area
        should_assign_to :exam
        should_assign_to :exam_version

        should_assign_to :exam_response
        should_assign_to :question_responses
      end
    end
  end

end
