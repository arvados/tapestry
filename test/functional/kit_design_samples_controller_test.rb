require 'test_helper'

class KitDesignSamplesControllerTest < ActionController::TestCase

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
        @count = KitDesignSample.count
        post :create
      end

      should_not set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not increase the kit design count' do
        assert_equal @count, KitDesignSample.count
      end
    end

    context "on GET to edit" do
      setup do
        kit_design_sample = Factory :kit_design_sample
        get :edit, :id => kit_design_sample.to_param
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

    context "on PUT to update" do
      setup do
        @kit_design_sample = Factory :kit_design_sample
        put :update, :id => @kit_design_sample.to_param, :kit_design_sample => { :description => 'Crazy new description' }
      end

      should_not set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end

      should 'not have updated the description' do
        assert_not_equal KitDesignSample.find(@kit_design_sample.to_param)[:description], 'Crazy new description'
      end
    end

    context "on DELETE to destroy" do
      setup do
        @kit_design_sample = Factory :kit_design_sample
        @count = KitDesignSample.count
        delete :destroy, :id => @kit_design_sample.to_param
      end

      should 'still be able to find the kit_design_sample' do
        assert KitDesignSample.find(@kit_design_sample)
      end

      should 'leave the kit_design_sample count as is' do
        assert_equal @count, KitDesignSample.count
      end

      should 'redirect appropriately' do
        assert_redirected_to login_path
      end
    end

  end

  logged_in_user_context do
    context "but not a researcher" do
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
          @count = KitDesignSample.count
          post :create
        end

        should_not set_the_flash.to /successfully created/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not increase the kit design count' do
          assert_equal @count, KitDesignSample.count
        end
      end

      context "on GET to edit, even if this user is somehow the owner of the kit_design_sample" do
        setup do
          kit_design_sample = Factory :kit_design_sample, :creator => @user
          get :edit, :id => kit_design_sample.to_param
        end

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end
      end

      context "on PUT to update, even if this user is somehow the owner of the kit_design_sample" do
        setup do
          @kit_design_sample = Factory :kit_design_sample, :creator => @user
          put :update, :id => @kit_design_sample.to_param, :kit_design_sample => { :description => 'Crazy new description' }
        end

        should_not set_the_flash.to /successfully updated/i

        should 'redirect appropriately' do
          assert_redirected_to unauthorized_user_path
        end

        should 'not have updated the description' do
          assert_not_equal KitDesignSample.find(@kit_design_sample.to_param)[:description], 'Crazy new description'
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
        @count = KitDesignSample.count
        sample_type = Factory(:sample_type)
        kit_design = Factory(:kit_design)
        kit_design_sample_attrs = Factory.attributes_for(:kit_design_sample).merge({:kit_design_id => kit_design[:id]})
        post :create, {
          :kit_design_sample => kit_design_sample_attrs,
          :sample_type_id => sample_type[:id]
        }
      end

      should set_the_flash.to /successfully created/i

      should 'redirect appropriately' do
        assert_redirected_to page_path( :researcher_tools )
      end

      should 'increase the kit design count' do
        assert_equal @count+1, KitDesignSample.count
      end
    end

    context "on GET to edit" do
      setup do
        kit_design_sample = Factory :kit_design_sample, :creator => @user
        get :edit, :id => kit_design_sample.to_param
      end

      should respond_with :success
      should render_template :edit
    end

    context "on PUT to update" do
      setup do
        @kit_design_sample = Factory :kit_design_sample, :creator => @user
        put :update, :id => @kit_design_sample.to_param, :kit_design_sample => { :description => 'Crazy new description' }
      end

      should set_the_flash.to /successfully updated/i

      should 'redirect appropriately' do
        assert_redirected_to page_path( :researcher_tools )
      end

      should 'have updated the description' do
        assert_equal assigns[:kit_design_sample][:description], 'Crazy new description'
        assert_equal KitDesignSample.find(@kit_design_sample)[:description], 'Crazy new description'
      end
    end


    context "on DELETE to destroy" do
      setup do
        @kit_design_sample = Factory :kit_design_sample, :creator => @user
        @count = KitDesignSample.count
        delete :destroy, :id => @kit_design_sample.to_param
      end

      should 'not be able to find the kit_design_sample' do
        assert_raise ActiveRecord::RecordNotFound do
          KitDesignSample.find(@kit_design_sample)
        end
      end

      should 'reduce the kit_design_sample count' do
        assert_equal @count-1, KitDesignSample.count
      end

      should 'redirect appropriately' do
        assert_redirected_to kit_design_samples_path
      end
    end

  end

end
