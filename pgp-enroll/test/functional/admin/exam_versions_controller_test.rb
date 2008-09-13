require 'test_helper'

class Admin::ExamVersionsControllerTest < ActionController::TestCase
  context 'when logged in as an admin, with an exam with versions' do
    setup do
      @user = Factory :admin_user
      login_as @user
      @content_area = Factory(:content_area)
      @exam         = Factory(:exam, :content_area => @content_area)
      @version1     = Factory(:exam_version, :exam => @exam, :created_at => 3.minutes.ago, :published => false)
      @version2     = Factory(:exam_version, :exam => @exam, :created_at => 2.minutes.ago, :published => true)
    end

    context 'on GET to #index ' do
      setup { get :index, :content_area_id => @content_area, :exam_id => @exam }

      should_respond_with :success
      should_render_template :index
      should_assign_to :exam_verions

      should 'have a link to each exam version' do
        @exam.versions.each do |version|
          assert_select 'a[href=?]', admin_content_area_exam_exam_version_path(@content_area, @exam, @exam_version)
        end
      end
    end


    should "get new" do
      get :new, :content_area_id => @content_area
      assert_response :success
    end

    should "create exam" do
      assert_difference('Exam.count') do
        exam_hash = Factory.attributes_for(:exam, :content_area => @content_area)
        post :create, :content_area_id => @content_area, :exam => exam_hash
      end

      assert_redirected_to admin_content_area_exam_versions_path(@content_area)
    end

    should "show exam" do
      get :show, :content_area_id => @content_area, :id => @exam
      assert_response :success
    end

    should "get edit" do
      get :edit, :content_area_id => @content_area, :id => @exam
      assert_response :success
    end

    should "update exam" do
      put :update, :content_area_id => @content_area, :id => @exam, :exam => { }
      assert_redirected_to admin_content_area_exam_version_path(@content_area, assigns(:exam))
    end

    should "destroy exam definition" do
      assert_difference('ExamVersion.count', -1) do
        delete :destroy, :content_area_id => @content_area, :id => @exam_version.id
      end

      assert_redirected_to :action => 'index'
    end
  end
end
