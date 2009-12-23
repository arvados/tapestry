require 'test_helper'

class Admin::InvitedEmailsControllerTest < ActionController::TestCase
  should_route :get, '/admin/invited_emails', :controller => 'admin/invited_emails', :action => 'index'

  context 'when logged in as a non-admin' do
    setup do
      @user = Factory(:user)
      @user.activate!
      assert !@user.is_admin?

      login_as @user
    end

    should 'not allow access' do
      get :index
      assert_response :redirect
      assert_redirected_to login_url
    end
  end

  context 'when logged in as an admin' do
    setup do
      @user = Factory(:user, :is_admin => true)
      @user.activate!
      assert @user.is_admin?

      login_as @user
    end

    context 'with some invited emails' do
      setup do
        5.times { Factory(:invited_email) }
      end

      context 'on GET index' do
        setup do
          get :index
        end

        should_respond_with :success
        should_render_template :index

        should "assign to @invited_emails" do
          assert assigns(:invited_emails)
        end

        should "assign to @number_of_accepted_emails" do
          assert_equal InvitedEmail.accepted.count, assigns(:number_of_accepted_emails)
        end

        should "show the invites" do
          InvitedEmail.all.each do |invited_email|
            assert_match invited_email.created_at.to_s,  @response.body
            assert_match invited_email.email,            @response.body
            assert_match invited_email.accepted_at.to_s, @response.body
          end
        end

        should "link to new" do
          assert_select 'a[href=?]', new_admin_invited_email_path
        end
      end
    end

    context 'on GET to new' do
      setup do
        get :new
      end

      should "render a form with a text area that POSTs to create" do
        assert_select 'form[method=post][action=?]', admin_invited_emails_path do
          assert_select 'textarea[name=?]', 'emails'
        end
      end
    end

    context 'on POST to create' do
      setup do
        post :create, :emails => "a@b.com\nc@d.com"
      end

      should_change "InvitedEmail.count", :by => 2
      should_redirect_to "admin_invited_emails_path"
    end
  end

end
