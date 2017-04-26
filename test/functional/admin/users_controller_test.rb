require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  logged_in_user_context do

    should 'not allow access to the admin/users controller' do
      get :index
      assert_response :redirect
      assert_redirected_to unauthorized_user_path
    end
  end

  logged_in_as_admin do

    context 'on GET to show a user' do
      setup do
        @user = Factory(:user)
        Factory(:waitlist, :user => @user, :reason => "Banana sundae")
        Factory(:enrollment_step)
        get :show, :id => @user.id
      end

      should respond_with :success
      should render_template :show

      should "link to #promote for each user" do
        assert_select 'a[href=?]', promote_admin_user_path(@user)
      end

      should "show that user's waitlists" do
        assert_match /Banana sundae/, @response.body
      end

    end

    context "on PUT to update for a user" do
      setup do
        @user = Factory(:user)
        @mailing_list = Factory :mailing_list
        put :update, :id => @user.to_param, :user => { "is_admin" => "1", "email" => "newemail@example.com", "mailing_list_ids" => [ @mailing_list.id ] }
      end

      should respond_with :redirect
      should 'redirect to the correct path' do
        assert_redirected_to admin_users_path
      end

      should "update the user" do
        assert @user.reload.is_admin?
        assert_equal "newemail@example.com", @user.reload.email
        assert_equal @user.mailing_list_ids, [ @mailing_list.id ]
      end
    end

    context 'with some users' do
      setup do
        5.times { Factory(:user) }
      end

      context 'on GET to index, requesting to list all users' do
        setup do
          get :index, :all => true
        end

        should 'show all users' do
          User.all.each do |user|
            assert_select 'td', user.email
          end
        end

      end

      context 'on GET to index' do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index

        should "render a dropdown to filter users by completed enrollment step" do
          assert_select 'form[action=?][method=get]', admin_users_path do
            assert_select 'select[name=?]', 'completed'
            assert_select 'input[type=submit]'
          end
        end

        should "render a link to filter only inactive users" do
          assert_select 'li>a[href=?]', admin_users_path(:inactive => true)
        end

        should "render a link to the bulk-promote-user page" do
          assert_select 'li>a[href=?]', new_admin_bulk_promotion_path
        end

        should "render a link to the bulk-waitlist-user page" do
          assert_select 'li>a[href=?]', new_admin_bulk_waitlist_path(:phase => 'preenroll')
        end

        should "render an enroll link to the bulk-waitlist-user page" do
          assert_select 'li>a[href=?]', new_admin_bulk_waitlist_path(:phase => 'enroll')
        end
      end

      should 'show as CSV on GET to index, requesting all publishable users' do
        get :index, :all => true, :format => 'csv'
        assert_response :success
        User.publishable.each do |user|
          assert_match user.email, @response.body
        end
      end

      should "show users who have not yet activated when params[:inactive] is specified" do
        inactive_user  = Factory(:user,           :first_name => "Ralph")
        activated_user = Factory(:activated_user, :first_name => "Lauren")

        get :index, :inactive => true

        assert_response :success
        assert_equal User.inactive, assigns(:users)
      end

      should "show users who have completed a certain enrollment step when params[:completed] is specified" do
        step = Factory(:enrollment_step, :keyword => 'some_step')
        completed_user = Factory(:user)
        completed_user.complete_enrollment_step(step)

        get :index, :completed => 'some_step'

        assert_response :success
        assert_equal [completed_user], assigns(:users)
      end

      should "show users who are enrolled when filter is specified" do
        users = [Factory(:user)]
        User.expects(:enrolled).once.returns(users)

        get :index, :enrolled => true

        assert_equal users, assigns(:users)
        assert_select 'a[href=?]', admin_users_url(:format => 'csv', :enrolled => true)
      end

      should 'link to the CSV download with the same filter when params[:completed] is specified' do
        get :index, :completed => 'some_step'
        assert_select 'a[href=?]', admin_users_url(:format => 'csv', :completed => 'some_step')
      end
    end

    should 'activate user on PUT to #activate' do
      inactive_user = Factory(:user)
      put :activate, :id => inactive_user
      assert inactive_user.reload.active?
    end

    should 'promote user on PUT to #promote' do
      user = Factory(:user)
      enrollment_step_completions_count = user.enrollment_step_completions.count

      put :promote, :id => user.to_param

      assert_equal enrollment_step_completions_count+1, user.reload.enrollment_step_completions.count
      assert_match /User promoted/, flash[:notice]
    end

    should 'delete user on DELETE' do
      @another_user = Factory(:user)
      delete :destroy, :id => @another_user
      assert_raises ActiveRecord::RecordNotFound do
        get :edit, :id => @another_user
      end
    end
  end

end
