require 'test_helper'

class ThirdPartyControllerTest < ActionController::TestCase

  logged_in_enrolled_user_context do

    context 'open humans section enabled' do

      setup do
        ApplicationController.any_instance.stubs('include_section?').with(Section::OPEN_HUMANS).returns(true)
      end

      context 'but no existing open humans service' do
        should 'not freak out' do
          get :index
          assert_response :success
        end
      end

      context 'existing open humans service but no existing token' do

        setup do
          @oauth_service = Factory(:open_humans_oauth_service)
        end

        should 'display index' do
          get :index
          assert_response :success
          assert_not_nil assigns(:open_humans_services)
        end
      end

    end
  end
end