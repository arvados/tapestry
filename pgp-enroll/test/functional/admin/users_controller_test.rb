require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  context 'when logged in as a non-admin' do
    setup do
      @user = Factory(:user)
      @user.activate!
      login_as @user
    end

    should 'not allow access to the admin/users controller' do
      get :index
      assert_response :redirect
      assert_redirected_to login_url
    end
  end

  context 'when logged in as an admin' do
    setup do
      @admin = Factory(:admin_user)
      @admin.activate!
      login_as @admin
    end

    context 'on GET to edit for a user' do
      setup do
        @user = Factory(:user)
        Factory(:enrollment_step)
        get :edit, :id => @user.id
      end

      should_respond_with :success
      should_render_template :edit

      should "link to #promote for each user" do
        assert_select 'a[href=?]', promote_admin_user_url(@user)
      end

      should_eventually "render the edit form"
    end

    context 'with some users' do
      setup do
        5.times { Factory(:user) }
      end

      context 'on GET to index' do
        setup do
          get :index
        end

        should_respond_with :success
        should_render_template :index

        should 'show all users' do
          User.all.each do |user|
            assert_select 'td', user.email
          end
        end

        should "render a dropdown to filter users by completed enrollment step" do
          assert_select 'form[action=?][method=get]', admin_users_path do
            assert_select 'select[name=?]', 'completed'
            assert_select 'input[type=submit]'
          end
        end

        should "render a link to filter only inactive users" do
          assert_select 'li>a[href=?]', admin_users_path(:inactive => true)
        end

        should "render a link to show only users who are in group 1 (best match)" do
          assert_select 'li>a[href=?]',admin_users_path(:screening_eligibility_group => 1)
        end

        should "render a link to show only users who are in group 2 (ok match)" do
          assert_select 'li>a[href=?]', admin_users_path(:screening_eligibility_group => 2)
        end

        should "render a link to show only users who are in group 3 (ok match)" do
          assert_select 'li>a[href=?]', admin_users_path(:screening_eligibility_group => 3)
        end

        should "render a link to the bulk-promote-user page" do
          assert_select 'li>a[href=?]', new_admin_bulk_promotion_path
        end
      end

      should 'show all users on GET to index as CSV' do
        get :index, :format => 'csv'
        assert_response :success

        User.all.each do |user|
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

      should "filter users who are in a screening_eligibility_group when params[:screening_eligibility_group] is specified" do
        users = [Factory(:user)]
        User.expects(:in_screening_eligibility_group).with(1).once.returns(users)

        get :index, :screening_eligibility_group => "1"

        assert_equal users, assigns(:users)
        assert_select 'a[href=?]', formatted_admin_users_url(:format => 'csv', :screening_eligibility_group => "1")
      end

      should 'link to the CSV download with the same filter when params[:completed] is specified' do
        get :index, :completed => 'some_step'
        assert_select 'a[href=?]', formatted_admin_users_url(:format => 'csv', :completed => 'some_step')
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
