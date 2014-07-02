require 'test_helper'

class AcceptedInvitesControllerTest < ActionController::TestCase

  should route(:post, '/accepted_invites').to(:action => 'create')

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

    should 'redirect to the correct path' do
      assert_redirected_to page_path(:introduction)
    end
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

    should set_the_flash.to /invite/i
    should 'redirect to the correct path' do
      assert_redirected_to page_path(:home)
    end
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

    should set_the_flash.to /already/i
    should 'redirect to the correct path' do
      assert_redirected_to page_path(:home)
    end
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

    should set_the_flash.to /invite/i
    should 'redirect to the correct path' do
      assert_redirected_to page_path(:home)
    end
  end
end
