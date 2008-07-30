require File.dirname(__FILE__) + '/../test_helper'

class HomesControllerTest < ActionController::TestCase
  context "with a logged in user and some enrollment steps completed and some left remaining on GET to index" do
    setup do
      @user = Factory :user
      @steps = []
      5.times { @steps << Factory(:enrollment_step) }
      3.times { |n| @user.complete_enrollment_step @steps[n] }

      login_as @user
      get :index
    end

    should "see the logged in user homepage" do
      assert_template 'homes/index'
      assert_select 'h2', /Logged in/
    end

    should "see enrollment steps" do
      @steps.each do |step|
        assert_select 'li', /#{step.title}/
      end
    end

    should "only have one enrollment step available to click on" do
      assert_select 'ol#enrollment_steps>li>a', { :text => @steps[3].title, :count => 1 }
    end
  end

  context "with a stranger on GET to index" do
    setup do
      get :index
    end

    should "have only the signup step available to click on" do
      assert_equal 'signup', assigns(:next_step).keyword
      assert_select 'ol#enrollment_steps>li>a', { :text => assigns(:next_step).title, :count => 1 }
    end
  end
end
