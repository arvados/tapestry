require 'test_helper'

class ExportsControllerTest < ActionController::TestCase
  setup do
    ApplicationController.any_instance.stubs('include_section?').with(Section::PUBLIC_DATA).returns(true)
  end

  test 'exports/phrccr_lab_test_results.csv' do
    get :phrccr_lab_test_results, :format => :csv
    assert_response :success
    assert_match /\bzz43860C\b/, response.body
    assert_match /\bWeight\b/, response.body
    assert_match /\b3936\b/, response.body
    assert_match /\bounces\b/, response.body
  end

  test 'exports/phrccr_lab_test_results.csv disabled' do
    ApplicationController.any_instance.stubs('include_section?').with(Section::PUBLIC_DATA).returns(false)
    get :phrccr_lab_test_results, :format => :csv
    assert_response :redirect
  end
end
