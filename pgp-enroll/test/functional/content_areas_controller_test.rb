require 'test_helper'

class ContentAreasControllerTest < ActionController::TestCase
  context 'with a logged in user and several content areas' do
    setup do
      @user = Factory(:user)
      # @user.activate!
      login_as @user
      3.times do
        content_area = Factory(:content_area)
        exam = Factory(:exam, :content_area => content_area)
        Factory(:exam_version, :exam => exam, :published => false, :created_at => @user.created_at - 2.minutes)
        Factory(:exam_version, :exam => exam, :published => true,  :created_at => @user.created_at - 1.minute)
      end
    end

    context 'on GET to index' do
      setup { get :index }

      should_respond_with :success
      should_render_template :index

      should 'show the content areas' do
        ContentArea.all.each do |area|
          assert_select 'li', /#{area.title}/
        end
      end
    end

    context 'when some exams do not have versions for the current user' do
      setup do
        Exam.any_instance.expects(:version_for).returns(nil)
      end

      context 'on GET to show' do
        setup do
          @content_area = ContentArea.first
          get :show, :id => @content_area
        end

        should_assign_to :exams

        should 'assign some exams' do
          assert assigns(:exams).any?
        end

        should 'not actually display any exams' do
          assigns(:exams).each do |exam|
            assert_select 'a[href=?]',
                          content_area_exam_path(@content_area, exam),
                          :count => 0
          end
        end
      end
    end

    context 'on GET to show' do
      setup do
        @content_area = ContentArea.first
        get :show, :id => @content_area
      end

      should_respond_with :success
      should_render_template :show
      should_assign_to :exams

      should 'show, for each exam, the version for the current_user' do
        assigns(:exams).each do |exam|
          assert_select 'a[href=?]',
                        content_area_exam_path(@content_area, exam),
                        :text => /#{exam.version_for(@user).title}/
        end
      end
    end
  end
end
