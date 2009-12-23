require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase

  should 'route /admin/reports to Admin::ReportsController#index' do
    assert_routing(
        { :path => '/admin/reports', :method => 'GET' },
        { :controller => 'admin/reports', :action => 'index' } )
  end

  context 'when logged in as a non-admin' do
    setup do
      @user = Factory(:user)
      @user.activate!
      login_as @user
    end

    context 'on GET to index' do
      setup { get :index }
      should_redirect_to 'login_url'
    end
  end

  context 'when logged in as an admin' do
    setup do
      @user = Factory(:admin_user)
      @user.activate!
      login_as @user
    end

    context 'on GET to index' do
      setup { get :index }

      should_respond_with :success
      should_render_template :index

      should_assign_to 'passed_entrance_exam_count'
      should_assign_to 'content_areas'
    end
  end
end

