require 'test_helper'

class SamplesControllerTest < ActionController::TestCase

  should_eventually 'test the other samples_controller actions: participant_note, update_participant_note, mark_as_destroyed, and many others'

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should respond_with :success
      should render_template :index
    end

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
        @count = Sample.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the sample count' do
        assert_equal @count, Sample.count
      end
    end

    context "on GET to edit" do
      setup do
        sample = Factory :sample
        get :edit, :id => sample.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on GET to show" do
      setup do
        sample = Factory :sample
        get :show, :id => sample.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @sample = Factory :sample
        put :update, :id => @sample.to_param, :sample => { :researcher_note => 'Crazy new researcher_note' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the researcher_note' do
        assert_not_equal Sample.find(@sample.to_param)[:researcher_note], 'Crazy new researcher_note'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @sample = Factory :sample
        @count = Sample.count
        delete :destroy, :id => @sample.to_param
      end

      should 'still be able to find the sample' do
        assert Sample.find(@sample)
      end

      should 'leave the sample count as is' do
        assert_equal @count, Sample.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do
    context "but not a researcher" do
      context "on GET to index" do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index
      end

      context "on GET to new" do
        setup do
          get :new
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on POST to create" do
        setup do
          @count = Sample.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the sample count' do
          assert_equal @count, Sample.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the sample" do
        setup do
          sample = Factory :sample, :creator => @user, :owner => @user
          get :edit, :id => sample.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on GET to show, even if this user is somehow the owner of the sample" do
        setup do
          sample = Factory :sample, :creator => @user, :owner => @user
          get :show, :id => sample.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the sample" do
        setup do
          @sample = Factory :sample, :creator => @user, :owner => @user
          put :update, :id => @sample.to_param, :sample => { :researcher_note => 'Crazy new researcher_note' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the researcher_note' do
          assert_not_equal Sample.find(@sample.to_param)[:researcher_note], 'Crazy new researcher_note'
        end
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
        @count = Sample.count
        post :create, :sample => Factory.attributes_for(:sample)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to sample_path(assigns(:sample))
      end

      should 'increase the sample count' do
        assert_equal @count+1, Sample.count
      end
    end

    context "on GET to edit" do
      setup do
        sample = Factory :sample, :creator => @user, :owner => @user
        get :edit, :id => sample.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on GET to show" do
      setup do
        sample = Factory :sample, :creator => @user, :owner => @user
        get :show, :id => sample.to_param
      end

      should respond_with :success
      should render_template :show
    end

    context "on PUT to update" do
      setup do
        @sample = Factory :sample, :creator => @user, :owner => @user
        put :update, :id => @sample.to_param, :sample => { :researcher_note => 'Crazy new researcher_note' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to sample_path(@sample.to_param)
      end

      should 'have updated the researcher_note' do
        assert_equal assigns[:sample][:researcher_note], 'Crazy new researcher_note'
        assert_equal Sample.find(@sample)[:researcher_note], 'Crazy new researcher_note'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @sample = Factory :sample, :creator => @user, :owner => @user
        @count = Sample.count
        delete :destroy, :id => @sample.to_param
      end

      should 'not be able to find the sample' do
        assert_raise ActiveRecord::RecordNotFound do
          Sample.find(@sample)
        end
      end

      should 'reduce the sample count' do
        assert_equal @count-1, Sample.count
      end

      should 'redirect appropriately' do
        assert_redirected_to samples_path
      end
    end

  end

end
