require 'test_helper'

class KitsControllerTest < ActionController::TestCase

  context "without a logged in user" do
    context "on GET to index" do
      setup do
        get :index
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on GET to show" do
      setup do
        kit = Factory :kit
        get :show, :id => kit.id
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
        @count = Kit.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the kit count' do
        assert_equal @count, Kit.count
      end
    end

    context "on GET to edit" do
      setup do
        kit = Factory :kit
        get :edit, :id => kit.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @kit = Factory :kit
        put :update, :id => @kit.to_param, :kit => { :name => 'Crazy new name' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the name' do
        assert_not_equal Kit.find(@kit.to_param)[:name], 'Crazy new name'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @kit = Factory :kit
        @count = Kit.count
        delete :destroy, :id => @kit.to_param
      end

      should 'still be able to find the kit' do
        assert Kit.find(@kit)
      end

      should 'leave the kit count as is' do
        assert_equal @count, Kit.count
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

      context "on GET to show" do
        setup do
          kit = Factory :kit
          get :show, :id => kit.to_param
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
          @count = Kit.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the kit count' do
          assert_equal @count, Kit.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the kit" do
        setup do
          kit = Factory :kit, :owner => @user
          get :edit, :id => kit.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the kit" do
        setup do
          @kit = Factory :kit, :owner => @user
          put :update, :id => @kit.to_param, :kit => { :name => 'Crazy new name' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the name' do
          assert_not_equal Kit.find(@kit.to_param)[:name], 'Crazy new name'
        end
      end

    end
  end

  logged_in_researcher_context do

    should_eventually "test the rest of the actions (claim, confirm_claim, returned, sent, etc.)"

    context "on GET to new" do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context "on POST to create" do
      setup do
        @count = Kit.count
        post :create, {
          :number_of_kits_to_create => '1',
          :kit => Factory.attributes_for(:kit)
        }
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end

      should 'increase the kit count' do
        assert_equal @count+1, Kit.count
      end
    end

    context "on GET to edit" do
      setup do
        kit = Factory :kit, :owner => @user
        get :edit, :id => kit.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to kit_path(assigns[:kit].to_param)
      end
    end

    context "on PUT to update" do
      setup do
        @next_name = Factory.next(:kit_name)
        @kit = Factory :kit, :owner => @user
        put :update, :id => @kit.to_param, :kit => { :name => @next_name }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end

      should 'have updated the name' do
        assert_equal assigns[:kit][:name], @next_name
        assert_equal Kit.find(@kit)[:name], @next_name
      end
    end


    context "on DELETE to destroy" do
      setup do
        @kit = Factory :kit, :owner => @user
        @count = Kit.count
        delete :destroy, :id => @kit.to_param
      end

      should 'not be able to find the kit' do
        assert_raise ActiveRecord::RecordNotFound do
          Kit.find(@kit)
        end
      end

      should 'reduce the kit count' do
        assert_equal @count-1, Kit.count
      end

      should 'redirect appropriately' do
        assert_redirected_to root_path
      end
    end

  end

end
