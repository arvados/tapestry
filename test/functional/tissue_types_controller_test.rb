require 'test_helper'

class TissueTypesControllerTest < ActionController::TestCase

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
        @count = TissueType.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the tissue_type count' do
        assert_equal @count, TissueType.count
      end
    end

    context "on GET to edit" do
      setup do
        tissue_type = Factory :tissue_type
        get :edit, :id => tissue_type.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @tissue_type = Factory :tissue_type
        put :update, :id => @tissue_type.to_param, :tissue_type => { :name => 'Crazy new name' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the name' do
        assert_not_equal TissueType.find(@tissue_type.to_param)[:name], 'Crazy new name'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @tissue_type = Factory :tissue_type
        @count = TissueType.count
        delete :destroy, :id => @tissue_type.to_param
      end

      should 'still be able to find the tissue_type' do
        assert TissueType.find(@tissue_type)
      end

      should 'leave the tissue_type count as is' do
        assert_equal @count, TissueType.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do
    context "but not admin" do
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
          @count = TissueType.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the tissue_type count' do
          assert_equal @count, TissueType.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the tissue_type" do
        setup do
          tissue_type = Factory :tissue_type, :creator => @user
          get :edit, :id => tissue_type.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the tissue_type" do
        setup do
          @tissue_type = Factory :tissue_type, :creator => @user
          put :update, :id => @tissue_type.to_param, :tissue_type => { :name => 'Crazy new name' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the name' do
          assert_not_equal TissueType.find(@tissue_type.to_param)[:name], 'Crazy new name'
        end
      end

    end
  end

  logged_in_as_admin do

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = TissueType.count
        post :create, :tissue_type => Factory.attributes_for(:tissue_type)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to tissue_types_path
      end

      should 'increase the tissue_type count' do
        assert_equal @count+1, TissueType.count
      end
    end

    context "on GET to edit" do
      setup do
        tissue_type = Factory :tissue_type, :creator => @user
        get :edit, :id => tissue_type.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @tissue_type = Factory :tissue_type, :creator => @user
        put :update, :id => @tissue_type.to_param, :tissue_type => { :name => 'Crazy new name' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to tissue_types_path
      end

      should 'have updated the name' do
        assert_equal assigns[:tissue_type][:name], 'Crazy new name'
        assert_equal TissueType.find(@tissue_type)[:name], 'Crazy new name'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @tissue_type = Factory :tissue_type, :creator => @user
        @count = TissueType.count
        delete :destroy, :id => @tissue_type.to_param
      end

      should 'not be able to find the tissue_type' do
        assert_raise ActiveRecord::RecordNotFound do
          TissueType.find(@tissue_type)
        end
      end

      should 'reduce the tissue_type count' do
        assert_equal @count-1, TissueType.count
      end

      should 'redirect appropriately' do
        assert_redirected_to tissue_types_path
      end
    end

  end

end
