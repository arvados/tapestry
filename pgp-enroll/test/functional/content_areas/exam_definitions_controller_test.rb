require 'test_helper'

class ContentAreas::ExamDefinitionsControllerTest < ActionController::TestCase
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

    context 'on GET to show' do
      setup do
        get :show
        assert_response :success
      end

      #TODO: should...
    end
  end
end
