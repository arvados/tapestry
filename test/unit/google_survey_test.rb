require 'test_helper'

class GoogleSurveyTest < ActiveSupport::TestCase
  test 'old field id translated correctly' do
    s = GoogleSurvey.new(:userid_populate_entry => 10)
    assert_equal 1000010, s.userid_populate_entry
  end

  test 'new field id not translated at all' do
    s = GoogleSurvey.new(:userid_populate_entry => 2015123456)
    assert_equal 2015123456, s.userid_populate_entry
  end
end
