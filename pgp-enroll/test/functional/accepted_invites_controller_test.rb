require 'test_helper'

class AcceptedInvitesControllerTest < ActionController::TestCase
  should_route :post, '/accepted_invites', { :action => 'create' }

  context 'on POST to create for an invited email' do
    setup do
      @invited_email = Factory(:invited_email, :email => 'username@example.com')
      post :create, :email => 'username@example.com'
    end

    should "set invited in the session" do
      assert session[:invited]
    end

    should "mark that invite as accepted" do
      assert @invited_email.reload.accepted_at
    end

    should_redirect_to "page_url(:introduction)"
  end

  context 'on POST to create for a not-invited email' do
    setup do
      @email = 'foo@bar.com'
      assert ! InvitedEmail.first(:conditions => { :email => @email })
      post :create, :email => @email
    end

    should "not set invited in the session" do
      assert ! session[:invited]
    end

    should_set_the_flash_to /invite/i
    should_redirect_to "page_url(:home)"
  end
end
