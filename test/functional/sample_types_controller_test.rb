require 'test_helper'

class SampleTypesControllerTest < ActionController::TestCase

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
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
        @count = SampleType.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the sample_type count' do
        assert_equal @count, SampleType.count
      end
    end

    context "on GET to edit" do
      setup do
        sample_type = Factory :sample_type
        get :edit, :id => sample_type.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on GET to show" do
      setup do
        sample_type = Factory :sample_type
        get :show, :id => sample_type.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @sample_type = Factory :sample_type
        put :update, :id => @sample_type.to_param, :sample_type => { :description => 'Crazy new description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the description' do
        assert_not_equal SampleType.find(@sample_type.to_param)[:description], 'Crazy new description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @sample_type = Factory :sample_type
        @count = SampleType.count
        delete :destroy, :id => @sample_type.to_param
      end

      should 'still be able to find the sample_type' do
        assert SampleType.find(@sample_type)
      end

      should 'leave the sample_type count as is' do
        assert_equal @count, SampleType.count
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

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
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
          @count = SampleType.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the sample_type count' do
          assert_equal @count, SampleType.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the sample_type" do
        setup do
          sample_type = Factory :sample_type, :creator => @user
          get :edit, :id => sample_type.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on GET to show, even if this user is somehow the owner of the sample_type" do
        setup do
          sample_type = Factory :sample_type, :creator => @user
          get :show, :id => sample_type.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the sample_type" do
        setup do
          @sample_type = Factory :sample_type, :creator => @user
          put :update, :id => @sample_type.to_param, :sample_type => { :description => 'Crazy new description' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the description' do
          assert_not_equal SampleType.find(@sample_type.to_param)[:description], 'Crazy new description'
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
        @count = SampleType.count
        post :create, :sample_type => Factory.attributes_for(:sample_type)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to sample_types_path
      end

      should 'increase the sample_type count' do
        assert_equal @count+1, SampleType.count
      end
    end

    context "on GET to edit" do
      setup do
        sample_type = Factory :sample_type, :creator => @user
        get :edit, :id => sample_type.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on GET to show" do
      setup do
        sample_type = Factory :sample_type, :creator => @user
        get :show, :id => sample_type.to_param
      end

      should respond_with :success
      should render_template :show
    end

    context "on PUT to update" do
      setup do
        @sample_type = Factory :sample_type, :creator => @user
        put :update, :id => @sample_type.to_param, :sample_type => { :description => 'Crazy new description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to sample_types_path
      end

      should 'have updated the description' do
        assert_equal assigns[:sample_type][:description], 'Crazy new description'
        assert_equal SampleType.find(@sample_type)[:description], 'Crazy new description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @sample_type = Factory :sample_type, :creator => @user
        @count = SampleType.count
        delete :destroy, :id => @sample_type.to_param
      end

      should 'not be able to find the sample_type' do
        assert_raise ActiveRecord::RecordNotFound do
          SampleType.find(@sample_type)
        end
      end

      should 'reduce the sample_type count' do
        assert_equal @count-1, SampleType.count
      end

      should 'redirect appropriately' do
        assert_redirected_to sample_types_path
      end
    end

  end

end
