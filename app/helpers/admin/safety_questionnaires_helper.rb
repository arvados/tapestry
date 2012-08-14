module Admin::SafetyQuestionnairesHelper
  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_safety_questionnaires(safety_questionnaires, question)

    # precache associations
    safety_questionnaires = SafetyQuestionnaire.find(safety_questionnaires.map(&:id),
        :include => [:user]).sort { |x,y| x.datetime <=> y.datetime }

    user_fields = %w(hex).freeze
    if question.nil? then
      safety_questionnaire_fields = %w(datetime has_changes events reactions contact healthcare).freeze
    else
      question = question.to_i
      question_field = ['events','reactions','contact','healthcare'][question - 1]
      safety_questionnaire_fields = ['datetime', question_field].freeze
    end

    buf = ''

    header_row = user_fields.map(&:humanize)
    header_row += safety_questionnaire_fields.map(&:humanize)

    CSV.generate_row(header_row, header_row.size, buf)
    safety_questionnaires.each do |sq|
      if not question.nil? then
        # If this is the question-specific report, do not include lines when the participant left the response blank for this question
        next if sq.send(question_field) == ''
      end

      row = []
      user_fields.each do |field|
        row.push sq.user.send(field)
      end

      safety_questionnaire_fields.each do |field|
        row.push sq.send(field)
      end
      CSV.generate_row(row, row.size, buf)
    end

    buf
  end
end

