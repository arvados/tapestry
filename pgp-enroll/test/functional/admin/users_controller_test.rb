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
          assert_response :success
        end

        should 'show all users' do
          User.all.each do |user|
            assert_select 'td', user.email
          end
        end
      end

      context 'on GET to index as CSV' do
        setup do
          get :index, :format => 'csv'
          assert_response :success
        end

        should 'show all users' do
          User.all.each do |user|
            assert_match user.email, @response.body
          end
        end
      end

      context 'where some, but not all, users have completed the enrollment exam' do
        setup do
          assert @exams_step = EnrollmentStep.find_by_keyword('content_areas')
          @completed_users = [Factory(:user)]
          @uncompleted_users = [Factory(:user)]
          @completed_users.each { |u| Factory(:enrollment_step_completion, :enrollment_step => @exams_step, :user => u) }
        end

        context 'on GET to index with ?completed_enrollment_exam=true' do
          setup do
            get :index, :completed_enrollment_exam => true
          end

          should_respond_with :success
          should_render_template :index

          should 'show all users who have completed the enrollment exam' do
            assigns(:users).each do |user|
              assert user.completed_enrollment_steps.include?(@exams_step)
            end
          end

          should 'link to the CSV download with the same filter' do
            assert_select 'a[href=?]', formatted_admin_users_url(:format => 'csv', :completed_enrollment_exam => true)
          end
        end
      end
    end

    should 'activate user on PUT to #activate' do
      @inactive_user = Factory(:user)
      put :activate, :id => @inactive_user
      @inactive_user.reload
      assert @inactive_user.active?
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
