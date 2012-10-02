require 'test_helper'

class PublicGeneticDataCellTest < Cell::TestCase
  test "list" do
    invoke :list
    assert_select "p"
  end
  

end
