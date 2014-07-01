require 'test_helper'

class UserLogTest < ActiveSupport::TestCase
  context 'a user log entry' do
    should belong_to :user
    should belong_to :enrollment_step

    should validate_presence_of :user_id
  end

end
