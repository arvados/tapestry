class NormalizeCheckAllAnswers < ActiveRecord::Migration
  class QuestionResponse < ActiveRecord::Base
  end

  def self.up
    QuestionResponse.all.each do |qr|
      qr.update_attributes(:answer => qr.answer.split(',').map(&:to_i).sort.join(','))
    end
  end

  def self.down
  end
end
