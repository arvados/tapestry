require 'test_helper'

class Admin::ExamsControllerTest < ActionController::TestCase

  logged_in_as_admin do

    context 'with exams' do
      setup do
        @exam_version = Factory :exam_version
        @exam         = @exam_version.exam
        @content_area = @exam.content_area
      end

      context 'on GET to index' do
        setup { get :index, :content_area_id => @content_area }

        should_respond_with :success
        should_render_template :index
        should_assign_to :exams
      end

      context 'on GET to show' do
        setup { get :show, :content_area_id => @content_area, :id => @exam }

        should_redirect_to 'admin_content_area_exam_exam_versions_url(@content_area, @exam)'
      end

      context 'on POST to create' do
        setup do
          @count = Exam.count
          exam_hash = Factory.attributes_for(:exam, :content_area => @content_area)
          post :create, :content_area_id => @content_area, :exam => exam_hash
          @exam = Exam.last
        end

        should_redirect_to 'admin_content_area_exams_path(@content_area)'
        # PH: FIXME: really? What if the flash were "Sorry, the content area could not be created."
        should_set_the_flash_to /created/i

        should 'increase the number of exams by 1' do
          assert_equal @count+1, Exam.count
        end
      end

      context 'on DELETE to destroy' do
        setup do
          @count = Exam.count
          delete :destroy, :content_area_id => @content_area, :id => @exam.id
        end

        should_redirect_to 'admin_content_area_exams_path(@content_area)'

        should 'change the count of exams by -1' do
          assert_equal @count-1, Exam.count
        end
      end
    end
  end
end
