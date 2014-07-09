require 'test_helper'

class PlatesControllerTest < ActionController::TestCase

  context "without a logged in user" do
    context "on POST to create" do
      setup do
        @count = Plate.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the plate count' do
        assert_equal @count, Plate.count
      end
    end

    context "on GET to show" do
      setup do
        plate = Factory :plate
        get :show, :id => plate.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @plate = Factory :plate
        put :update, :id => @plate.to_param, :plate => { :description => 'Crazy new description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the description' do
        assert_not_equal Plate.find(@plate.to_param)[:description], 'Crazy new description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @plate = Factory :plate
        @count = Plate.count
        delete :destroy, :id => @plate.to_param
      end

      should 'still be able to find the plate' do
        assert Plate.find(@plate)
      end

      should 'leave the plate count as is' do
        assert_equal @count, Plate.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do
    context "but not a researcher" do
      context "on POST to create" do
        setup do
          @count = Plate.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the plate count' do
          assert_equal @count, Plate.count
        end
      end

      context "on PUT to update" do
        setup do
          @plate = Factory :plate
          put :update, :id => @plate.to_param, :plate => { :description => 'Crazy new description' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the description' do
          assert_not_equal Plate.find(@plate.to_param)[:description], 'Crazy new description'
        end
      end

    end
  end

  logged_in_researcher_context do

    context "on POST to create" do
      setup do
        @count = Plate.count
        post :create, :plate => Factory.attributes_for(:plate)
      end

      should set_the_flash.to /successfully created/i

      should 'increase the plate count' do
        assert_equal @count+1, Plate.count
      end
    end

    context "on GET to show" do
      setup do
        plate = Factory :plate, :creator => @user
        get :show, :id => plate.to_param
      end

      should respond_with :success
      should render_template :show
    end

    context "on PUT to update" do
      setup do
        @plate = Factory :plate, :creator => @user
        put :update, :id => @plate.to_param, :plate => { :description => 'Crazy new description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to plate_path(@plate.to_param)
      end

      should 'have updated the description' do
        assert_equal assigns[:plate][:description], 'Crazy new description'
        assert_equal Plate.find(@plate)[:description], 'Crazy new description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @plate = Factory :plate, :creator => @user
        @count = Plate.count
        delete :destroy, :id => @plate.to_param
      end

      should 'not be able to find the plate' do
        assert_raise ActiveRecord::RecordNotFound do
          Plate.find(@plate)
        end
      end

      should 'reduce the plate count' do
        assert_equal @count-1, Plate.count
      end

      should 'redirect appropriately' do
        assert_redirected_to plates_path
      end
    end

    should_eventually 'test other actions: dup, prepare_layout_grid, mobile, etc.'

  end

end
