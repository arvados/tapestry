require 'test_helper'

class Admin::ExamResponsesControllerTest < ActionController::TestCase

  should "route /admin/exam_responses to Admin::ExamResponsesController#index" do
    assert_routing '/admin/exam_responses', :controller => 'admin/exam_responses',
                                            :action     => 'index'
  end

  should "route /admin/exam_responses/show to Admin::ExamResponsesController#show" do
    assert_routing '/admin/exam_responses/1', :controller => 'admin/exam_responses',
                                              :action     => 'show',
                                              :id         => '1'
  end

  should_only_allow_admins_on 'get :show'

  logged_in_as_admin do
    context 'with some exam responses' do
      setup do
        @exam_responses = []
        5.times { @exam_responses << Factory(:exam_response) }
      end

      context 'on GET to index' do
        setup do
          get :index
        end

        should_respond_with :success
        should_render_template :index
        should_assign_to :exam_responses
      end

      context 'on GET to show' do
        setup do
          @exam_response = @exam_responses.first
          get :show, :id => @exam_response
        end

        should_respond_with :success
        should_render_template :show
        should_assign_to :exam_response
      end
    end
  end

end
