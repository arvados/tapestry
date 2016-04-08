require 'test_helper'

class UserFilesControllerTest < ActionController::TestCase
  logged_in_enrolled_user_context do
    setup do
      @user_file = FactoryGirl.create(:user_file,
                                      :user => @user)
      @dataset_report = FactoryGirl.create(:dataset_report,
                                           :user_file => @user_file)
    end

    should "link to dataset report" do
      get :index
      assert_response :success
      assert assigns(:user_files).any?
      assert_select "table tr"
      assert_select "table td:content(other)"
      assert_select "table td a[href$='/dataset_reports/#{@dataset_report.id}']"
    end
  end
end
