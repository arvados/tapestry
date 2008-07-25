require File.dirname(__FILE__) + '/../test_helper'

class HomesControllerTest < ActionController::TestCase
  context "with a logged in user on the homepage" do
    setup do
      login_as :quentin
      get :index 
    end

    should "see the logged in user homepage" do
      assert_template 'homes/index'
      assert_select 'h2', /Logged in/
    end

    should "see enrollment steps" do
      EnrollmentStep.all.each do |step|
        assert_select 'li', /#{step.title}/
      end
    end
  end
end
