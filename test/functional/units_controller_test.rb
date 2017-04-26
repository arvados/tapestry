require 'test_helper'

class UnitsControllerTest < ActionController::TestCase

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
        @count = Unit.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the unit count' do
        assert_equal @count, Unit.count
      end
    end

    context "on GET to edit" do
      setup do
        unit = Factory :unit
        get :edit, :id => unit.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @unit = Factory :unit
        put :update, :id => @unit.to_param, :unit => { :name => 'Crazy new name' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the name' do
        assert_not_equal Unit.find(@unit.to_param)[:name], 'Crazy new name'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @unit = Factory :unit
        @count = Unit.count
        delete :destroy, :id => @unit.to_param
      end

      should 'still be able to find the unit' do
        assert Unit.find(@unit)
      end

      should 'leave the unit count as is' do
        assert_equal @count, Unit.count
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
          @count = Unit.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the unit count' do
          assert_equal @count, Unit.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the unit" do
        setup do
          unit = Factory :unit, :creator => @user
          get :edit, :id => unit.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the unit" do
        setup do
          @unit = Factory :unit, :creator => @user
          put :update, :id => @unit.to_param, :unit => { :name => 'Crazy new name' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the name' do
          assert_not_equal Unit.find(@unit.to_param)[:name], 'Crazy new name'
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
        @count = Unit.count
        post :create, :unit => Factory.attributes_for(:unit)
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to units_path
      end

      should 'increase the unit count' do
        assert_equal @count+1, Unit.count
      end
    end

    context "on GET to edit" do
      setup do
        unit = Factory :unit, :creator => @user
        get :edit, :id => unit.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @unit = Factory :unit, :creator => @user
        put :update, :id => @unit.to_param, :unit => { :name => 'Crazy new name' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to units_path
      end

      should 'have updated the name' do
        assert_equal assigns[:unit][:name], 'Crazy new name'
        assert_equal Unit.find(@unit)[:name], 'Crazy new name'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @unit = Factory :unit, :creator => @user
        @count = Unit.count
        delete :destroy, :id => @unit.to_param
      end

      should 'not be able to find the unit' do
        assert_raise ActiveRecord::RecordNotFound do
          Unit.find(@unit)
        end
      end

      should 'reduce the unit count' do
        assert_equal @count-1, Unit.count
      end

      should 'redirect appropriately' do
        assert_redirected_to units_path
      end
    end

  end

end
