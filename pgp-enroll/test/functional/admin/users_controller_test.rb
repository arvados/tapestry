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
      @user = Factory(:admin_user)
      @user.activate!
      login_as @user
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

        should "link to #promote for each user" do
          User.all.each do |user|
            assert_select 'td a[href=?]', promote_admin_user_url(@user)
          end
        end

        should "render a dropdown to filter users by completed enrollment step" do
          assert_select 'form[action=?][method=get]', admin_users_path do
            assert_select 'select[name=?]', 'completed'
            assert_select 'input[type=submit]'
          end
        end
      end

      should 'show all users on GET to index as CSV' do
        get :index, :format => 'csv'
        assert_response :success

        User.all.each do |user|
          assert_match user.email, @response.body
        end
      end

      should "show users who have completed a certain enrollment step when params[:completed] is specified" do
        step = Factory(:enrollment_step, :keyword => 'some_step')
        completed_user = Factory(:user)
        completed_user.complete_enrollment_step(step)

        get :index, :completed => 'some_step'

        assert_response :success
        assert_equal [completed_user], assigns(:users)
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
