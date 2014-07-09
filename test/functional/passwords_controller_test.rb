require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase

  should route(:get, "/password/new").to(:controller => 'passwords',
                                         :action => 'new')

  context 'GET to new' do
    setup do
      get :new
    end

    should respond_with :success
    should render_template :new

    should 'render a form that posts to create with email address' do
      assert_select 'form[action=?]', password_url do
        assert_select 'input[name=?]', 'password[email]'
        assert_select 'input[type=submit]'
      end
    end
  end

  context 'POST to create when user exists' do
    setup do
      @user = Factory(:activated_user)
      ActionMailer::Base.deliveries = []
      User.stubs(:find_by_email).returns(@user)
      post :create, :password => { :email => 'email@address.com' }
    end

    should 'send an email' do
      assert_equal 1, ActionMailer::Base.deliveries.size
      email = ActionMailer::Base.deliveries.first
      assert_equal [@user.email], email.to
    end

    should 'redirect appropriately' do
      assert_redirected_to root_path
    end

    should set_the_flash.to /an email has been sent to email@address.com/i

  end

  should 'say no such account exists on POST to create where the user does not exist' do
    User.stubs(:find_by_email).returns(nil)
    post :create, :password => { :email => 'email@address.com' }

    assert_redirected_to(new_password_url)
    assert_match /we could not find an account with that email address/i, flash[:notice]
  end

  should "deny GET to edit if key is not present" do
    get :edit
    assert_match /invalid password reset link/, flash[:warning]
    assert_redirected_to root_url
  end

  should "deny GET to edit if key does not match any user" do
    get :edit, :id => '-1', :key => 'adsf'
    assert_match /invalid password reset link/, flash[:warning]
    assert_redirected_to root_url
  end

  context "GET to edit with valid key" do
    setup do
      @user = Factory(:activated_user)
      get :edit, :id => @user.id, :key => @user.crypted_password
    end

    should respond_with :success
    should render_template :edit

    should "render a form that PUTs to update that allows password update and contains key" do
      assert_select 'form[action=?]', password_url do
        assert_select 'input[type=hidden][name=_method][value=?]', 'put'
        assert_select 'input[type=hidden][name=?][value=?]', 'password[id]', @user.id
        assert_select 'input[type=hidden][name=?][value=?]', 'password[key]', @user.crypted_password
        assert_select 'input[type=password][name=?]', 'password[password]'
        assert_select 'input[type=submit]'
      end
    end
  end

  should "redirect on PUT to update with bad key" do
    User.stubs(:find_by_id_and_crypted_password).returns(nil)
    put :update, :password => { :id => '-1', :key => 'asdf', :password => 'newpassword' }

    assert_match /invalid password reset link/, flash[:warning]
    assert_redirected_to root_url
  end

  context 'on PUT to update with valid key but bad password confirmation' do
    setup do
      @user = Factory(:activated_user)
      #User.stubs(:find_by_id_and_crypted_password).with(user[:id], user[:crypted_password]).returns(user)

      put :update, :password => { :id => @user[:id],
                                  :key => @user[:crypted_password],
                                  :password => 'newpassword',
                                  :password_confirmation => 'xxx' }
    end

    should set_the_flash.to /Your password could not be reset/i

    should 'redirect appropriately' do
      assert_redirected_to edit_password_path(:id => @user[:id], :key => @user[:crypted_password])
    end

  end

  should "update the user and redirect on PUT to update with valid key and good password confirmation" do
    user = Factory(:activated_user)

    put :update, :password => { :id => user.id,
                                :key => user.crypted_password,
                                :password => 'newpassword',
                                :password_confirmation => 'newpassword'
                              }

    assert_equal user, User.authenticate(user.email, 'newpassword')

    assert_match /reset your password successfully/, flash[:notice]
    assert_redirected_to login_url
  end
end
