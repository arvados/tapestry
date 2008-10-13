require 'test_helper'

class ContentAreaTest < ActiveSupport::TestCase

  context 'with a content area' do
    setup do
      @content_area = Factory :content_area
    end

    should_have_many :exams
    should_require_attributes :title, :description

    context 'with many exams' do
      setup do
        2.times do
          Factory(:exam_version,
                  :exam       => Factory(:exam, :content_area => @content_area),
                  :created_at => 2.weeks.ago)
        end
      end

      context 'with all exams completed by a user' do
        setup do
          @user = Factory(:user, :created_at => 1.week.ago)

          @content_area.exams.each do |exam|
            ExamResponse.create({
              :user         => @user,
              :exam_version => exam.version_for(@user)
            })
          end
        end

        should 'return false when sent #completed_by?(user)' do
          assert ! @content_area.completed_by?(@user)
        end
      end

      context 'with all exams completed by a user that have a version for that user' do
        setup do
          @user = Factory(:user, :created_at => 1.week.ago)

          @exam_version_not_for_user = Factory(:exam_version,
           :exam => Factory(:exam,
                            :created_at   => @user.created_at - 1.day,
                            :content_area => @content_area))

          @content_area.exams.each do |exam|
            ExamResponse.create({
              :user         => @user,
              :exam_version => exam.version_for(@user)
            })
          end
        end

        should 'return false when sent #completed_by?(user)' do
          assert ! @content_area.completed_by?(@user)
        end
      end

      context 'without all exams completed by a user' do
        setup do
          @user = Factory(:user, :created_at => 1.week.ago)
          ExamResponse.create({
            :user         => @user,
            :exam_version => @content_area.exams.first.version_for(@user)
          })
        end

        should 'return false when sent #completed_by?(user)' do
          assert ! @content_area.completed_by?(@user)
        end
      end
    end
  end

end
