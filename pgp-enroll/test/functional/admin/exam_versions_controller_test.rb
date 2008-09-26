require 'test_helper'

class Admin::ExamVersionsControllerTest < ActionController::TestCase

  should 'route to #index' do
    assert_routing(
        { :path => '/admin/content_areas/1/exams/1/exam_versions', :method => 'GET' },
        { :controller => 'admin/exam_versions', :action => 'index', :content_area_id => '1', :exam_id => '1'} )
  end

  should 'route to #show' do
    assert_routing(
        { :path => '/admin/content_areas/1/exams/1/exam_versions/1', :method => 'GET' },
        { :controller => 'admin/exam_versions', :action => 'show', :content_area_id => '1', :exam_id => '1', :id => '1' } )
  end

  context 'when logged in as an admin, with an exam with versions' do
    setup do
      @user = Factory :admin_user
      login_as @user
      @content_area  = Factory(:content_area)
      @exam          = Factory(:exam, :content_area => @content_area)
      @version1      = Factory(:exam_version, :exam => @exam, :created_at => 3.minutes.ago, :published => false)
      @version2      = Factory(:exam_version, :exam => @exam, :created_at => 2.minutes.ago, :published => true)
      @exam_versions = [@version1, @version2]
    end

    context 'on GET to #index ' do
      setup { get :index, :content_area_id => @content_area, :exam_id => @exam }

      should_respond_with :success
      should_render_template :index
      should_assign_to :exam
      should_assign_to :exam_versions

      should 'have a link to each exam version' do
        @exam_versions.each do |version|
          assert_select 'a[href=?]', admin_content_area_exam_exam_version_path(@content_area, @exam, version)
          assert_select 'td', :text => version.version
        end
      end
    end

    context "on GET to #new" do
      setup do
        get :new, :content_area_id => @content_area, :exam_id => @exam
      end

      should_respond_with :success
      should_render_template :new
    end

    context 'on POST to #create' do
      setup do
        @old_exam_version_count = @exam.versions.count
        exam_version_hash = Factory.attributes_for(:exam_version, :exam => @exam)
        post :create, :content_area_id => @content_area, :exam_id => @exam, :exam_version => exam_version_hash
      end

      should_redirect_to 'admin_content_area_exam_exam_versions_path(@content_area, @exam)'

      should 'create another exam version' do
        assert_equal @old_exam_version_count+1, @exam.versions.count
      end
    end

    context 'on POST to #duplicate' do
      setup do
        @old_exam_version_count = @exam.versions.count
        post :duplicate, :content_area_id => @content_area, :exam_id => @exam, :id => @version2
        @exam.reload
      end

      should 'create another exam version' do
        assert_equal @old_exam_version_count+1, @exam.versions.count
      end

      should 'duplicate the specified exam' do
        @version3 = @exam.versions.last
        assert_equal @version2.exam_questions.count, @version3.exam_questions.count
      end

      should_eventually 'duplicate the specified exam, all the way down the tree' do
      end
    end

    context 'on GET to #show' do
      setup do
        get :show, :content_area_id => @content_area, :exam_id => @exam, :id => @version1
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :exam_version
    end

    context 'on GET to #edit' do
      setup do
        get :edit, :content_area_id => @content_area, :exam_id => @exam, :id => @version1
      end

      should_respond_with :success
      should_render_template :edit
      should_assign_to :exam_version

      should 'have a form that PUTs to #update' do
        assert_select 'form[action=?]', admin_content_area_exam_exam_version_path(@content_area, @exam, @version1)
      end
    end

    context 'on PUT to #update' do
      setup do
        @exam_version_hash = Factory.attributes_for(:exam_version, :exam => @exam)
        put :update, :content_area_id => @content_area, :exam_id => @exam, :id => @version1, :exam_version => @exam_version_hash
      end

      should_redirect_to 'admin_content_area_exam_exam_versions_path(@content_area, @exam)'

      should 'update the attributes' do
        @version1.reload
        [:title, :description, :version, :published?].each do |key|
          assert_equal @exam_version_hash[key], @version1[key]
        end
      end
    end

    context 'on DELETE to #destroy' do
      setup do
        @old_exam_version_count = @exam.versions.count
        delete :destroy, :content_area_id => @content_area, :exam_id => @exam, :id => @version1
      end

      should 'decrement the number of versions by 1' do
        assert_equal @old_exam_version_count-1, @exam.versions.count
      end

      should_redirect_to 'admin_content_area_exam_exam_versions_path(@content_area, @exam)'
    end
  end
end
