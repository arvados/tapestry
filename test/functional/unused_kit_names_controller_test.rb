require 'test_helper'

class UnusedKitNamesControllerTest < ActionController::TestCase

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
        @count = UnusedKitName.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the unused_kit_name count' do
        assert_equal @count, UnusedKitName.count
      end
    end

    context "on GET to edit" do
      setup do
        unused_kit_name = Factory :unused_kit_name
        get :edit, :id => unused_kit_name.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @unused_kit_name = Factory :unused_kit_name
        put :update, :id => @unused_kit_name.to_param, :unused_kit_name => { :name => 'Crazy new name' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the name' do
        assert_not_equal UnusedKitName.find(@unused_kit_name.to_param)[:name], 'Crazy new name'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @unused_kit_name = Factory :unused_kit_name
        @count = UnusedKitName.count
        delete :destroy, :id => @unused_kit_name.to_param
      end

      should 'still be able to find the unused_kit_name' do
        assert UnusedKitName.find(@unused_kit_name)
      end

      should 'leave the unused_kit_name count as is' do
        assert_equal @count, UnusedKitName.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do
    context "but not researcher" do
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
          @count = UnusedKitName.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the unused_kit_name count' do
          assert_equal @count, UnusedKitName.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the unused_kit_name" do
        setup do
          unused_kit_name = Factory :unused_kit_name, :creator => @user
          get :edit, :id => unused_kit_name.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the unused_kit_name" do
        setup do
          @unused_kit_name = Factory :unused_kit_name, :creator => @user
          put :update, :id => @unused_kit_name.to_param, :unused_kit_name => { :name => 'Crazy new name' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the name' do
          assert_not_equal UnusedKitName.find(@unused_kit_name.to_param)[:name], 'Crazy new name'
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
        @count = UnusedKitName.count
        post :create, :unused_kit_name => Factory.attributes_for(:unused_kit_name)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to unused_kit_name_path(assigns(:unused_kit_name).to_param)
      end

      should 'increase the unused_kit_name count' do
        assert_equal @count+1, UnusedKitName.count
      end
    end

    context "on GET to edit" do
      setup do
        unused_kit_name = Factory :unused_kit_name, :creator => @user
        get :edit, :id => unused_kit_name.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @unused_kit_name = Factory :unused_kit_name, :creator => @user
        put :update, :id => @unused_kit_name.to_param, :unused_kit_name => { :name => 'Crazy new name' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to unused_kit_name_path(@unused_kit_name)
      end

      should 'have updated the name' do
        assert_equal assigns[:unused_kit_name][:name], 'Crazy new name'
        assert_equal UnusedKitName.find(@unused_kit_name)[:name], 'Crazy new name'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @unused_kit_name = Factory :unused_kit_name, :creator => @user
        @count = UnusedKitName.count
        delete :destroy, :id => @unused_kit_name.to_param
      end

      should 'not be able to find the unused_kit_name' do
        assert_raise ActiveRecord::RecordNotFound do
          UnusedKitName.find(@unused_kit_name)
        end
      end

      should 'reduce the unused_kit_name count' do
        assert_equal @count-1, UnusedKitName.count
      end

      should 'redirect appropriately' do
        assert_redirected_to unused_kit_names_path
      end
    end

  end

end
