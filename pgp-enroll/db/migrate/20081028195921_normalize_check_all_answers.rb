class Exam < ActiveRecord::Base
end

class ExamVersion < ActiveRecord::Base
end

class ExamQuestion < ActiveRecord::Base
  belongs_to :exam_version
end

class QuestionResponse < ActiveRecord::Base
  belongs_to :exam_question
  before_save :normalize_answer

  def normalize_answer
    unless self.answer.blank?
      if self.exam_question.kind == 'CHECK_ALL'
        self.answer = self.answer.split(',').map(&:to_i).sort.join(',')
      end
    end
  end
end

class NormalizeCheckAllAnswers < ActiveRecord::Migration
  def self.up
    QuestionResponse.all.each do |qr|
      qr.answer = qr.answer.split(',').map(&:to_i).sort.join(',')
      qr.save
    end
  end

  def self.down
  end
end
