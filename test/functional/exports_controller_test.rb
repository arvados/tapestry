require 'test_helper'

class ExportsControllerTest < ActionController::TestCase
  setup do
    ApplicationController.any_instance.stubs('include_section?').with(Section::PUBLIC_DATA).returns(true)
  end

  test 'exports/users.csv' do
    get :users, :format => :csv
    assert_response :success
    assert_match /\b#{users(:pgp1).hex}\b/, response.body
    assert_no_match /\b#{users(:suspended).hex}\b/, response.body
  end

  test 'exports/datasets.csv' do
    get :datasets, :format => :csv
    assert_response :success
    assert_match /\b#{datasets(:published).human_id}\b.*\b#{datasets(:published).sha1}\b/, response.body
    assert_match /\b#{datasets(:published_anonymously).sha1}\b/, response.body
    assert_no_match /\b#{datasets(:published).human_id}\b.*\b#{datasets(:published_anonymously).sha1}\b/, response.body
    assert_no_match /\b#{datasets(:for_suspended_user).sha1}\b/, response.body
    assert_no_match /\b#{datasets(:deleted).sha1}\b/, response.body
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
