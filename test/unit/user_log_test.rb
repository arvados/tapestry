require 'test_helper'

class UserLogTest < ActiveSupport::TestCase
  context 'a user log entry' do
    should_belong_to :user
    should_belong_to :enrollment_step

    should_validate_presence_of :user_id
  end

end
