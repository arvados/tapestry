require 'test_helper'

class Admin::InvitedEmailsControllerTest < ActionController::TestCase
  should route( :get, '/admin/invited_emails' ).to( :controller => 'admin/invited_emails', :action => 'index' )

  logged_in_user_context do

    should 'not allow access' do
      get :index
      assert_response :redirect
      assert_redirected_to unauthorized_user_path
    end
  end

  logged_in_as_admin do

    context 'with some invited emails' do
      setup do
        5.times { Factory(:invited_email) }
      end

      context 'on GET index' do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index

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
        @count = InvitedEmail.count
        post :create, :emails => "a@b.com\nc@d.com"
      end

      should 'increase the invited emails count by 2' do
        assert_equal @count+2, InvitedEmail.count
      end
      should 'redirect to the correct path' do
        assert_redirected_to admin_invited_emails_path
      end
    end
  end

end
