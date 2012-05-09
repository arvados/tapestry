require 'test_helper'

class NewsItemCellTest < Cell::TestCase
  test "feed" do
    invoke :feed
    assert_select "p"
  end
  

end
