require File.dirname(__FILE__) + '/../test_helper'
require 'user_mailer'

class UserMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  should "set the right edit_password_url in password_reset email" do
    user = Factory(:user)
    email = UserMailer.create_password_reset(user)
    assert email.body.include?(edit_password_url(:id => user.id, :key => user.crypted_password)), 
      "email body should include password reset url in:\n#{email.body}"
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_mailer/#{action}")
    end

end
