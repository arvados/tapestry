require 'test_helper'

class Admin::MailingListsControllerTest < ActionController::TestCase

  logged_in_as_admin do

    context 'with mailing lists' do
      setup do
        @mailing_list = Factory :mailing_list
      end 

      should "get index" do
        get :index
        assert_response :success
        assert_not_nil assigns(:mailing_lists)
      end

      should "get new" do
        get :new
        assert_response :success
      end 

      should "create mailing list" do
        assert_difference('MailingList.count') do
          post :create, :mailing_list => Factory.attributes_for(:mailing_list)
        end

        assert_redirected_to admin_mailing_lists_path
      end

      should "get edit" do
        get :edit, :id => @mailing_list.id
        assert_response :success
      end 

      should "update mailing list" do
        put :update, :id => @mailing_list.id, :mailing_list => { } 
        assert_redirected_to admin_mailing_lists_path
      end 

      should "destroy mailing list" do
        assert_difference('MailingList.count', -1) do
          delete :destroy, :id => @mailing_list.id
        end 

        assert_redirected_to admin_mailing_lists_path
      end 
      
    end
  end
end
