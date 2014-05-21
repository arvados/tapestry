class ActiveSupport::TestCase

  include AuthenticatedTestHelper

  def self.logged_in_user_context(&blk)
    context 'as an activated and logged in user' do
      setup do
        @user = Factory :user
        @user.activate!
        @user.accept_tos if APP_CONFIG['ensure_tos']
        login_as @user
      end

      merge_block(&blk)
    end
  end

  def self.public_context(&blk)
    context 'as a public visitor' do
      setup do
        logout
      end

      merge_block(&blk)
    end
  end

  def self.logged_in_as_admin(&blk)
    context "A logged in admin" do
      setup do
        @user = Factory :admin_user
        @user.activate!
        @user.accept_tos if APP_CONFIG['ensure_tos']
        login_as @user
      end
      merge_block(&blk)
    end
  end

  def self.should_only_allow_admins_on(*actions)
    actions.each do |action|
      public_context do
        # should_deny_access_on action, :redirect => "login_url"
        should_eventually "deny access on #{action}: see test/macros/login.rb"
      end
    end
  end
end

