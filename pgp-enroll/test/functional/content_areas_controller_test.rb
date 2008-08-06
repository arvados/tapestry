require 'test_helper'

class ContentAreasControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory :user
      @user.activate!
      login_as @user
      3.times { Factory :content_area }
    end

    context 'on GET to index' do
      setup do
        get :index
        assert_response :success
      end

      should 'show the content areas' do
        ContentArea.all.each do |area|
          assert_select 'li', /#{area.title}/
        end
      end
    end

    context 'on GET to show' do
      setup do
        get :show
        assert_response :success
      end
    end
  end
end
