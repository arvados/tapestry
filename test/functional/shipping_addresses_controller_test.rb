require 'test_helper'

class ShippingAddressesControllerTest < ActionController::TestCase

  setup do
    ApplicationController.any_instance.stubs('include_section?').with(Section::SHIPPING_ADDRESS).returns(true)
  end

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
        @count = ShippingAddress.count
        post :create
      end

      should_not set_the_flash.to /successfully stored/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the shipping_address count' do
        assert_equal @count, ShippingAddress.count
      end
    end

    context "on GET to edit" do
      setup do
        shipping_address = Factory :shipping_address
        get :edit, :id => shipping_address.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @shipping_address = Factory :shipping_address
        put :update, :id => @shipping_address.to_param, :shipping_address => { :address_line_1 => 'Crazy new address_line_1' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the address_line_1' do
        assert_not_equal ShippingAddress.find(@shipping_address.to_param)[:address_line_1], 'Crazy new address_line_1'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @shipping_address = Factory :shipping_address
        @count = ShippingAddress.count
        delete :destroy, :id => @shipping_address.to_param
      end

      should 'still be able to find the shipping_address' do
        assert ShippingAddress.find(@shipping_address)
      end

      should 'leave the shipping_address count as is' do
        assert_equal @count, ShippingAddress.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_enrolled_user_context do

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = ShippingAddress.count
        post :create, :shipping_address => Factory.attributes_for(:shipping_address)
      end

      should set_the_flash.to /successfully stored/i

      should 'redirect appropriately' do
        assert_redirected_to edit_user_path(@user)
      end

      should 'increase the shipping_address count' do
        assert_equal @count+1, ShippingAddress.count
      end
    end

    context "on GET to edit" do
      setup do
        shipping_address = Factory :shipping_address, :user => @user
        get :edit, :id => shipping_address.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @shipping_address = Factory :shipping_address, :user => @user
        put :update, :id => @shipping_address.to_param, :shipping_address => { :address_line_1 => 'Crazy new address_line_1' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to edit_user_path(@user)
      end

      should 'have updated the address_line_1' do
        assert_equal assigns[:shipping_address][:address_line_1], 'Crazy new address_line_1'
        assert_equal ShippingAddress.find(@shipping_address)[:address_line_1], 'Crazy new address_line_1'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @shipping_address = Factory :shipping_address, :user => @user
        @count = ShippingAddress.count
        delete :destroy, :id => @shipping_address.to_param
      end

      should 'not be able to find the shipping_address' do
        assert_raise ActiveRecord::RecordNotFound do
          ShippingAddress.find(@shipping_address)
        end
      end

      should 'reduce the shipping_address count' do
        assert_equal @count-1, ShippingAddress.count
      end

      should 'redirect appropriately' do
        assert_redirected_to shipping_addresses_path
      end
    end

  end

end
