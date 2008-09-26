class Test::Unit::TestCase

  def self.logged_in_as_admin(&blk)
    context "A logged in admin" do
      setup do
        @user = Factory :admin_user
        login_as @user
      end
      merge_block(&blk)
    end
  end

end

