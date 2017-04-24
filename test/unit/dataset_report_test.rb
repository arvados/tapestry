require 'test_helper'

class DatasetReportTest < ActiveSupport::TestCase
  test 'cannot belong to both user_file and dataset' do
    r = DatasetReport.new(:dataset_id => 1,
                          :user_file_id => 1,
                          :display_url => 'https://example.com/')
    assert_equal false, r.valid?
  end

  test 'must belong to either user_file or dataset' do
    r = DatasetReport.new(:dataset => nil,
                          :user_file => nil,
                          :display_url => 'https://example.com/')
    assert_equal false, r.valid?
  end
end
