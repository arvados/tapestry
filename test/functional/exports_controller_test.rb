require 'test_helper'

class ExportsControllerTest < ActionController::TestCase
  setup do
    ApplicationController.any_instance.stubs('include_section?').with(Section::PUBLIC_DATA).returns(true)
  end

  test 'exports/users.csv' do
    get :users, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_no_match /\"#{users(:suspended).hex}\"/, response.body
  end

  test 'exports/datasets.csv' do
    get :datasets, :format => :csv
    assert_response :success
    assert_match /\"#{datasets(:published).human_id}\".*\"#{datasets(:published).sha1}\"/, response.body
    assert_match /\"#{datasets(:published_anonymously).sha1}\"/, response.body
    assert_no_match /\"#{datasets(:published).human_id}\".*\"#{datasets(:published_anonymously).sha1}\"/, response.body
    assert_no_match /\"#{datasets(:for_suspended_user).sha1}\"/, response.body
    assert_no_match /\"#{datasets(:deleted).sha1}\"/, response.body
  end

  test 'exports/user_files.csv' do
    get :user_files, :format => :csv
    assert_response :success
    assert_match /\"#{user_files(:published).user.hex}\".*\"#{Regexp.escape user_files(:published).locator}\"/, response.body
    assert_no_match /\"#{Regexp.escape user_files(:incomplete).dataset_file_name}\"/, response.body
    assert_no_match /\"#{users(:suspended).hex}\"/, response.body
  end

  test 'exports/phrccr_allergies.csv' do
    get :phrccr_allergies, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape allergies(:pgp1_ccr0_none_known).description}\"/, response.body
  end

  test 'exports/phrccr_conditions.csv' do
    get :phrccr_conditions, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape conditions(:pgp1_ccr0_hypersomnolence).description}\"/, response.body
  end

  test 'exports/phrccr_demographics.csv' do
    get :phrccr_demographics, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape demographics(:pgp1_ccr0).blood_type}\"/, response.body
  end

  test 'exports/phrccr_immunizations.csv' do
    get :phrccr_immunizations, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape immunizations(:pgp1_ccr0_tetanus).name}\"/, response.body
  end

  test 'exports/phrccr_lab_test_results.csv' do
    get :phrccr_lab_test_results, :format => :csv
    assert_response :success
    assert_match /\"zz43860C\"/, response.body
    assert_match /\"Weight\"/, response.body
    assert_match /\"3936\"/, response.body
    assert_match /\"ounces\"/, response.body
  end

  test 'exports/phrccr_medications.csv' do
    get :phrccr_medications, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape medications(:pgp1_ccr0_flonase).name}\"/, response.body
  end

  test 'exports/phrccr_procedures.csv' do
    get :phrccr_procedures, :format => :csv
    assert_response :success
    assert_match /\"#{users(:pgp1).hex}\"/, response.body
    assert_match /\"#{Regexp.escape procedures(:pgp1_ccr0_eye_exam).description}\"/, response.body
  end

  test 'exports/phrccr_lab_test_results.csv disabled' do
    ApplicationController.any_instance.stubs('include_section?').with(Section::PUBLIC_DATA).returns(false)
    get :phrccr_lab_test_results, :format => :csv
    assert_response :redirect
  end
end
