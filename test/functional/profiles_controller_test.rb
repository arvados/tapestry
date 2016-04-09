require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    ApplicationController.any_instance.
      stubs('include_section?').
      with(Section::PUBLIC_PROFILE).
      returns(true)

    @user = Factory(:enrolled_user)
    @user_file = FactoryGirl.create(:user_file,
                                    :user => @user)
    @dataset_report = FactoryGirl.create(:dataset_report,
                                         :user_file => @user_file)
    [@user, @user_file, @dataset_report].map(&:save!)
  end

  should "link to dataset report and download" do
    get :public, :hex => @user.hex
    assert_response :success
    assert_select("a[href='/dataset_reports/#{@dataset_report.id}']" +
                  ":content(View #{@dataset_report.title})")
    assert_select("a[href='/user_file/download/#{@user_file.id}']" +
                  "[rel=nofollow]" +
                  ":content(Download)")
  end
end
