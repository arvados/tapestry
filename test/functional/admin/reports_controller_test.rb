require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase

  should 'route /admin/reports to Admin::ReportsController#index' do
    assert_routing(
        { :path => '/admin/reports', :method => 'GET' },
        { :controller => 'admin/reports', :action => 'index' } )
  end

  logged_in_user_context do

    context 'on GET to index' do
      setup { get :index }
      should_redirect_to 'login_url'
    end
  end

  logged_in_as_admin do

    context 'on GET to index' do
      setup { get :index }

      should_respond_with :success
      should_render_template :index

      should_assign_to 'passed_entrance_exam_count'
      should_assign_to 'content_areas'
    end
  end
end

