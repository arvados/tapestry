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
      should 'redirect to unauthorized page' do
        assert_redirected_to unauthorized_user_path
      end
    end
  end

  logged_in_as_admin do

    context 'on GET to exam' do
      setup { get :exam }

      should respond_with :success
      should render_template :exam

      should assign_to 'passed_entrance_exam_count'
      should assign_to 'content_areas'
    end
  end
end

