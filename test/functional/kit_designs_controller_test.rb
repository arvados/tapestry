require 'test_helper'

class KitDesignsControllerTest < ActionController::TestCase

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
        @count = KitDesign.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the kit design count' do
        assert_equal @count, KitDesign.count
      end
    end

    context "on GET to edit" do
      setup do
        kit_design = Factory :kit_design
        get :edit, :id => kit_design.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @kit_design = Factory :kit_design
        put :update, :id => @kit_design.to_param, :kit_design => { :description => 'Crazy new description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the description' do
        assert_not_equal KitDesign.find(@kit_design.to_param)[:description], 'Crazy new description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @kit_design = Factory :kit_design
        @count = KitDesign.count
        delete :destroy, :id => @kit_design.to_param
      end

      should 'still be able to find the kit_design' do
        assert KitDesign.find(@kit_design)
      end

      should 'leave the kit_design count as is' do
        assert_equal @count, KitDesign.count
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
          @count = KitDesign.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the kit design count' do
          assert_equal @count, KitDesign.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the kit_design" do
        setup do
          kit_design = Factory :kit_design, :owner => @user, :creator => @user
          get :edit, :id => kit_design.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the kit_design" do
        setup do
          @kit_design = Factory :kit_design, :owner => @user, :creator => @user
          put :update, :id => @kit_design.to_param, :kit_design => { :description => 'Crazy new description' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the description' do
          assert_not_equal KitDesign.find(@kit_design.to_param)[:description], 'Crazy new description'
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
        @count = KitDesign.count
        post :create, :kit_design => Factory.attributes_for(:kit_design)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to page_path( :researcher_tools )
      end

      should 'increase the kit design count' do
        assert_equal @count+1, KitDesign.count
      end
    end

    context "on GET to edit" do
      setup do
        kit_design = Factory :kit_design, :owner => @user, :creator => @user
        get :edit, :id => kit_design.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @kit_design = Factory :kit_design, :owner => @user, :creator => @user
        put :update, :id => @kit_design.to_param, :kit_design => { :description => 'Crazy new description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to page_path( :researcher_tools )
      end

      should 'have updated the description' do
        assert_equal assigns[:kit_design][:description], 'Crazy new description'
        assert_equal KitDesign.find(@kit_design)[:description], 'Crazy new description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @kit_design = Factory :kit_design, :owner => @user, :creator => @user
        @count = KitDesign.count
        delete :destroy, :id => @kit_design.to_param
      end

      should 'not be able to find the kit_design' do
        assert_raise ActiveRecord::RecordNotFound do
          KitDesign.find(@kit_design)
        end
      end

      should 'reduce the kit_design count' do
        assert_equal @count-1, KitDesign.count
      end

      should 'redirect appropriately' do
        assert_redirected_to kit_designs_path
      end
    end

  end

end
