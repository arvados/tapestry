require 'test_helper'

class AcceptedInvitesControllerTest < ActionController::TestCase
  should_route :post, '/accepted_invites', { :action => 'create' }

  context 'on POST to create for an invited email that has not been accepted with the right invite code' do
    setup do
      @email = 'username@example.com'
      @invited_email = Factory(:invited_email, :email => @email, :accepted_at => nil)
      post :create, :email => @email, :code => InvitedEmail::INVITE_CODE
    end

    should "set invited in the session" do
      assert session[:invited]
    end

    should "set invited_email in the session" do
      assert_equal @email, session[:invited_email]
    end

    should "not mark that invite as accepted" do
      assert ! @invited_email.reload.accepted_at
    end

    should_redirect_to "page_url(:introduction)"
  end

  context 'on POST to create for an invited email that has not been accepted with the wrong invite code' do
    setup do
      @email = 'username@example.com'
      @invited_email = Factory(:invited_email, :email => @email, :accepted_at => nil)
      post :create, :email => @email, :code => "wrong-#{InvitedEmail::INVITE_CODE}"
    end

    should "not set invited in the session" do
      assert ! session[:invited]
    end

    should "not set invited_email in the session" do
      assert ! session[:invited_email]
    end

    should_set_the_flash_to /invite/i
    should_redirect_to "page_url(:home)"
  end

  context 'on POST to create for an invited email, with the right code, that has already been accepted' do
    setup do
      @email = 'username@example.com'
      @invited_email = Factory(:invited_email, :email => @email, :accepted_at => 1.day.ago)
      post :create, :email => @email, :code => InvitedEmail::INVITE_CODE
    end

    should "not set invited in the session" do
      assert ! session[:invited]
    end

    should "not set invited_email in the session" do
      assert ! session[:invited_email]
    end

    should_set_the_flash_to /already/i
    should_redirect_to "page_url(:home)"
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

    should "not set invited_email in the session" do
      assert ! session[:invited_email]
    end

    should_set_the_flash_to /invite/i
    should_redirect_to "page_url(:home)"
  end
end
