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
    end

    should "see enrollment steps" do
      @steps.each do |step|
        assert_select 'li', /#{step.title}/
      end
    end

    should "render completed steps as completed" do
      [0,1,2].each { |n| assert_select 'ol#enrollment_steps>li.completed>span.title', @steps[n].title }
    end

    should "only have one enrollment step available to click on" do
      assert_select 'ol#enrollment_steps>li>span.title>a', { :text => @steps[3].title, :count => 1 }
    end

    should "render locked steps as locked" do
      [4].each { |n| assert_select 'ol#enrollment_steps>li.locked>span.title', @steps[n].title }
    end
  end

  context "with a stranger on GET to index" do
    setup do
      Factory(:enrollment_step, :keyword => 'signup')
      get :index
    end

    should 'render public-facing copy to help orient new users' do
    end

    should 'link to the signup page' do
      assert_select 'a', :text => /informed consent/
    end

    should 'not render the enrollment steps' do
      assert_select 'ol#enrollment_steps', :count => 0
    end
  end

end
