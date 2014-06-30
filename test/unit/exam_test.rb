require 'test_helper'

class ExamTest < ActiveSupport::TestCase
  context 'given an exam' do
    setup do
      @exam = Factory :exam
    end

    should belong_to :content_area
    should have_many :versions

    context 'and no published versions' do
      setup do
        @version = Factory(:exam_version, :created_at => 5.minutes.ago, :exam => @exam, :version => 1, :published => false)
      end

      should 'return the most recent version title with (Unpublished) when sent #title' do
        assert_equal "#{@version.title} (Unpublished)", @exam.title
      end
    end

    context 'with multiple versions and a user' do
      setup do
        @version1 = Factory(:published_exam_version_with_question, :created_at => 5.minutes.ago, :exam => @exam, :version => 1)
        @version2 = Factory(:published_exam_version_with_question, :created_at => 4.minutes.ago, :exam => @exam, :version => 2)
        @user     = Factory(:user,         :created_at => 3.minutes.ago)
        @version3 = Factory(:published_exam_version_with_question, :created_at => 2.minutes.ago, :exam => @exam, :version => 3)
        @version4 = Factory(:published_exam_version_with_question, :created_at => 1.minute.ago,  :exam => @exam, :version => 4)
      end

      should 'return the title of its latest published version when sent #title' do
        assert_equal @version3.title, @exam.title
      end

      context 'when sent version_for' do
        setup do
          @version_for_user = @exam.version_for(@user)
        end

        should 'give the latest published version available' do
          other_published_versions = @exam.versions.published - [@version_for_user]

          if other_published_versions.any?
            other_published_versions.each do |other|
              assert other.created_at < @version_for_user.created_at
            end
          else
            # there are no "other" published exam versions
            assert @version_for_user == @exam.versions.published.first
          end
        end

        should 'give a published version' do
          assert @version_for_user.published?
        end

      end
    end
  end
end
