require 'test_helper'

class UserCellTest < Cell::TestCase
  test "dashboard_summary" do
    invoke :dashboard_summary
    assert_select "p"
  end
  

end
