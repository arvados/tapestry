module Admin::UsersHelper
  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_users(users)
    user_fields = %w(first_name last_name email activated_at phr_profile_name).freeze

    survey_response_fields = {
      :privacy   => %w(worrisome_information_comfort_level
                       information_disclosure_comfort_level
                       past_genetic_test_participation),

      :family    => %w(birth_year relatives_interested_in_pgp monozygotic_twin
                       child_situation youngest_child_birth_year),

      :residency => %w(us_resident country zip can_travel_to_boston)
    }.freeze

    baseline_traits_survey_fields = %w(sex health_insurance health_or_medical_conditions
      prescriptions_in_last_year allergies asian black
      hispanic native pacific white birth_year us_citizen birth_country paternal_grandfather_born_in
      paternal_grandmother_born_in maternal_grandfather_born_in maternal_grandmother_born_in)

    buf = ''

    header_row = user_fields.map(&:humanize)
    survey_response_fields.each do |survey, fields|
      header_row |= fields.map { |field| "#{survey.to_s.humanize} #{field.to_s.humanize}" }
    end
    header_row.push  "Waitlist Count"

    header_row.push "Informed Consent Twin"
    header_row.push "Informed Consent Biopsy"
    header_row.push "Informed Consent Recontact"

    header_row |= baseline_traits_survey_fields.map { |field| "Baseline traits survey #{field.to_s.humanize}" }

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

      row.push user.waitlists.count

      if user.informed_consent_response
        row.push user.informed_consent_response.twin
        row.push user.informed_consent_response.biopsy
        row.push user.informed_consent_response.recontact
      else
        3.times { row.push nil }
      end

      baseline_traits_survey_fields.each do |field|
        row.push(user.baseline_traits_survey ? user.baseline_traits_survey.send(field) : '-')
      end

      CSV.generate_row(row, row.size, buf)
    end

    buf
  end
end

