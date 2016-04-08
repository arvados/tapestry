require 'test_helper'

class DatasetReportsControllerTest < ActionController::TestCase
  test "view report for user_file" do
    get :show, {
      :id => FactoryGirl.create(:dataset_report, :for_user_file).id,
    }
    assert_redirected_to 'https://example.org/dataset_report/1234'
  end

  test "view report for published dataset" do
    get :show, {
      :id => FactoryGirl.create(:dataset_report, :for_published_dataset).id,
    }
    assert_redirected_to 'https://example.org/dataset_report/1234'
  end

  test "view report for unpublished dataset" do
    get :show, {
      :id => FactoryGirl.create(:dataset_report, :for_unpublished_dataset).id,
    }
    assert_response 404
  end
end
