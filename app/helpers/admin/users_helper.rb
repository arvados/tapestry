module Admin::UsersHelper

  def csv_for_failed_eligibility_survey()
    users = User.failed_eligibility_survey

    buf = ''
    header_row = ['Hash','Ineligibility reason(s)']

    CSV.generate_row(header_row, header_row.size, buf)
    users.each do |user|
      row = []
      row.push user.unique_hash
      row.push user.ineligible_for_enrollment.delete_if{ |x| x == 'Enrollment application not submitted'}.join(', ')
      CSV.generate_row(row, row.size, buf)
    end
    buf
  end

  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_users(users)

    # precache associations
    users = User.find(users.map(&:id),
        :include => [:distinctive_traits,
          :residency_survey_response,
          :family_survey_response,
          :privacy_survey_response,
          :baseline_traits_survey,
          :informed_consent_response,
          :waitlists])

    user_fields = %w(first_name last_name email hex activated_at phr_profile_name).freeze

    survey_response_fields = {
      :privacy   => %w(worrisome_information_comfort_level
                       information_disclosure_comfort_level
                       past_genetic_test_participation),

      :family    => %w(birth_year relatives_interested_in_pgp monozygotic_twin
                       child_situation youngest_child_birth_year),

      :residency => %w(resident country zip can_travel_to_pgphq)
    }.freeze

    baseline_traits_survey_fields = %w(sex health_insurance health_or_medical_conditions
      prescriptions_in_last_year allergies asian black
      hispanic native pacific white birth_year us_citizen birth_country paternal_grandfather_born_in
      paternal_grandmother_born_in maternal_grandfather_born_in maternal_grandmother_born_in)

    buf = ''

    header_row = user_fields.map(&:humanize)

    header_row.push "DOB"

    survey_response_fields.each do |survey, fields|
      header_row |= fields.map { |field| "#{survey.to_s.humanize} #{field.to_s.humanize}" }
    end
    header_row.push  "Waitlist Count"

    header_row.push "Informed Consent Twin"
    header_row.push "Informed Consent Biopsy"
    header_row.push "Informed Consent Recontact"

    baseline_traits_survey_fields.each do |field|
      header_row.push "Baseline traits survey #{field.to_s.humanize}"
    end

    header_row.push "Distinctive traits"
    header_row.push "Enrollment essay"

    header_row.push "Enrollment application result Has sequence"
    header_row.push "Enrollment application result Has sequence explanation"
    header_row.push "Enrollment application result Family members passed exam"

    header_row.push "Pledge"

    CSV.generate_row(header_row, header_row.size, buf)
    users.each do |user|

      row = []
      user_fields.each do |field|
        row.push user.send(field)
      end

      if user.ccrs.latest and user.ccrs.latest.demographic and user.ccrs.latest.demographic.dob
        row.push user.ccrs.latest.demographic.dob.to_s
      else
        row.push nil
      end

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

      row.push user.distinctive_traits.map { |trait| "#{trait.name} (#{trait.rating}/5)" }.join(", ")
      row.push user.enrollment_essay

      row.push user.has_sequence
      row.push user.has_sequence_explanation
      row.push user.family_members_passed_exam

      row.push user.pledge

      CSV.generate_row(row, row.size, buf)
    end

    buf
  end

  # Returns new filename for a csv report
  def generate_csv_filename(name, create_dir = true)
    f = "/data/#{ROOT_URL}/admin/reports/"

    if create_dir && !File.directory?(f)
      Dir.mkdir(f)
    end
    f = f + '/'

    timestamp = Time.now.strftime("%Y%m%d-%H%M%S")

    return f + "#{timestamp}-#{name}.csv"
  end

end

