module Admin::UsersHelper
  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_users(users)
    user_fields = %w(first_name last_name email activated_at).freeze

    survey_response_fields = {
      :privacy   => %w(worrisome_information_comfort_level
                       information_disclosure_comfort_level
                       past_genetic_test_participation),

      :family    => %w(birth_year relatives_interested_in_pgp monozygotic_twin
                       child_situation youngest_child_birth_year),

      :residency => %w(us_resident country zip can_travel_to_boston)
    }.freeze
    buf = ''

    header_row = user_fields.map(&:humanize)
    survey_response_fields.each do |survey, fields|
      header_row |= fields.map { |field| "#{survey.to_s.humanize} #{field.to_s.humanize}" }
    end

    CSV.generate_row(header_row, header_row.size, buf)
    users.each do |user|

      row = []
      row |= user_fields.map { |field| user.send(field) }

      survey_response_fields.each do |survey, fields|
        survey_response = user.send(:"#{survey}_survey_response")
        fields.each do |field|
          row.push(survey_response ? survey_response.send(field) : '-')
        end
      end

      CSV.generate_row(row, row.size, buf)
    end

    buf
  end
end

