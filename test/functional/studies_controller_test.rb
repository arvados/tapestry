require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

  should_eventually 'test the other actions: verify_participant_id, map, index_third_party, claim, users, etc.'

  context "without a logged in user" do

    context "on GET to new" do
      setup do
        get :new
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on POST to create" do
      setup do
        @count = Study.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the study count' do
        assert_equal @count, Study.count
      end
    end

    context "on GET to show" do
      setup do
        study = Factory :study
        get :show, :id => study.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @study = Factory :study
        put :update, :id => @study.to_param, :study => { :participant_description => 'Crazy new participant_description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the participant_description' do
        assert_not_equal Study.find(@study.to_param)[:participant_description], 'Crazy new participant_description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @study = Factory :study
        @count = Study.count
        delete :destroy, :id => @study.to_param
      end

      should 'still be able to find the study' do
        assert Study.find(@study)
      end

      should 'leave the study count as is' do
        assert_equal @count, Study.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_researcher_context do

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = Study.count
        post :create, :study => Factory.attributes_for(:study)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to page_path(:researcher_tools)
      end

      should 'increase the study count' do
        assert_equal @count+1, Study.count
      end
    end

    context "on GET to show" do
      setup do
        study = Factory :study, :creator => @user
        get :edit, :id => study.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @study = Factory :study, :creator => @user
        put :update, :id => @study.to_param, :study => { :participant_description => 'Crazy new participant_description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to page_path(:researcher_tools)
      end

      should 'have updated the participant_description' do
        assert_equal assigns[:study][:participant_description], 'Crazy new participant_description'
        assert_equal Study.find(@study)[:participant_description], 'Crazy new participant_description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @study = Factory :study, :creator => @user
        @count = Study.count
        delete :destroy, :id => @study.to_param
      end

      should 'not be able to find the study' do
        assert_raise ActiveRecord::RecordNotFound do
          Study.find(@study)
        end
      end

      should 'reduce the study count' do
        assert_equal @count-1, Study.count
      end

      should 'redirect appropriately' do
        assert_redirected_to collection_events_path
      end
    end

  end

  logged_in_enrolled_user_context do


  end

end
