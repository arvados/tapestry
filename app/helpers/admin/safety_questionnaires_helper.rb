module Admin::SafetyQuestionnairesHelper
  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_safety_questionnaires(safety_questionnaires)

    # precache associations
    safety_questionnaires = SafetyQuestionnaire.find(safety_questionnaires.map(&:id),
        :include => [:user])

    user_fields = %w(full_name).freeze
    safety_questionnaire_fields = %w(datetime changes events reactions contact healthcare).freeze

    buf = ''

    header_row = user_fields.map(&:humanize)
    header_row += safety_questionnaire_fields.map(&:humanize)

    CSV.generate_row(header_row, header_row.size, buf)
    safety_questionnaires.each do |sq|

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

