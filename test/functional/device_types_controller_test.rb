require 'test_helper'

class DeviceTypesControllerTest < ActionController::TestCase
  should "disallow a non-researcher to get index" do
    get :index
    assert_redirected_to login_path
  end

  logged_in_researcher_context do
    setup do
      @device_type = Factory( :device_type )
    end

    should "show index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:device_types)
    end

    should "get new" do
      get :new
      assert_response :success
    end

    context "create device_type" do
      setup do
        @count = DeviceType.count
        post :create, :device_type => { :name => Factory.next( :device_type_name ) }
      end

      should "increase device type count" do
        assert_equal (@count + 1), DeviceType.count
      end

      should "redirect correctly" do
        assert_redirected_to device_types_path
      end
    end

    should "get edit" do
      get :edit, :id => @device_type.to_param
      assert_response :success
    end

    should "update device_type description" do
      new_desc = 'New description'
      put :update, :id => @device_type.to_param, :device_type => { :description => new_desc }
      assert_equal new_desc, @device_type.reload.description
    end

    should "destroy device_type" do
      assert_difference('DeviceType.count', -1) do
        delete :destroy, :id => @device_type.to_param
      end

      assert_redirected_to device_types_path
    end

  end

end
