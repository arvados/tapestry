class Test::Unit::TestCase

  def self.public_context(&blk)
    context 'as a public visitor' do
      setup do
        logout_killing_session!
      end

      merge_block(&blk)
    end
  end

  def self.logged_in_as_admin(&blk)
    context "A logged in admin" do
      setup do
        @user = Factory :admin_user
        login_as @user
      end
      merge_block(&blk)
    end
  end

  def self.should_only_allow_admins_on(*actions)
    actions.each do |action|
      public_context do
        # should_deny_access_on action, :redirect => "login_url"
      end
    end
  end
end

