require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  include ApplicationHelper

  should 'route / to PagesController#show with an id of home' do
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => 'home' }, '/')
  end

  # This is a user that is not logged in, but the way Tapestry works will send us to a "create admin user" page
  # if there is not at least one user existant in the database.
  context 'not logged in' do
    setup do
      Factory :user
    end

    %w(home logged_out 23andme sitemap introduction withdrawal_menu).each do |page|
      context "on GET to /pages/#{page}" do
        setup do
          get :show, :id => page
        end

        should respond_with :success
        should render_template page
      end
    end

    %w(researcher_tools dashboard collection_events).each do |page|
      context "on GET to /pages/#{page}" do
        setup do
          get :show, :id => page
        end

        should "redirect appropriately for page='#{page}'" do
          case page
          when 'researcher_tools'
            assert_redirected_to unauthorized_user_path
          else
            assert_redirected_to login_path
          end
        end
      end
    end

    context 'on GET to /pages/non-existant-page' do
      setup do
        trap_exception { get :show, :id => 'non-existant-page' }
      end

      should_raise_exception ActionController::RoutingError
    end

  end


  logged_in_user_context do

    REDIRECTED_TO_ROOT = %w(collection_events)

    PagesController::PAGE_KEYWORDS.delete_if{|k| REDIRECTED_TO_ROOT.include? k }.each do |page|
      context "on GET to /pages/#{page}" do
        setup { get :show, :id => page }

        should respond_with :success
        should render_template page
      end
    end

    REDIRECTED_TO_ROOT.each do |page|
      context "on GET to /pages/#{page}" do
        setup do
          get :show, :id => page
        end

        should "redirect appropriately" do
          assert_redirected_to root_path
        end
      end
    end


    context 'on GET to /pages/home' do
      setup do
        get :show, :id => 'home'
      end

      should "assign enrollment_steps" do
        assert_equal EnrollmentStep.ordered, assigns(:steps)
      end

      should "show enrollment steps" do
        EnrollmentStep.all.collect{|es|es.title}.each do |title|
          assert_select 'span.title', /#{title}/
        end
      end

    end
  end

end
