require 'test_helper'

class Admin::UsersHelperTest < Test::Unit::TestCase

  context "with some users who have CSV-destined data" do
    setup do
      @user = Factory(:user,
          :phr_profile_name => "My PHR",
          :enrollment_essay => "My\nEssay",
          :has_sequence => true,
          :has_sequence_explanation => 'explanation',
          :family_members_passed_exam => 'response')

      Factory(:privacy_survey_response, :user => @user)
      Factory(:family_survey_response, :user => @user)
      Factory(:residency_survey_response, :user => @user)
      2.times { Factory(:waitlist, :user => @user) }
      Factory(:informed_consent_response, :user => @user)
      Factory(:baseline_traits_survey, :user => @user)
      2.times { Factory(:distinctive_trait, :user => @user) }

      @user_without_attached_data = Factory(:user)

      helper = stub('view')
      helper.extend(Admin::UsersHelper)

      @csv = helper.csv_for_users([@user, @user_without_attached_data])
    end

    should "render the proper headers when sent #csv_for_users" do
      values = {
        "First name" => @user.first_name,
        "Last name" => @user.last_name,
        "Email" => @user.email,
        "Activated at" => @user.activated_at,

        "Privacy Worrisome information comfort level" => @user.privacy_survey_response.worrisome_information_comfort_level,
        "Privacy Information disclosure comfort level" => @user.privacy_survey_response.information_disclosure_comfort_level,
        "Privacy Past genetic test participation" => @user.privacy_survey_response.past_genetic_test_participation,

        "Family Birth year" => @user.family_survey_response.birth_year,
        "Family Relatives interested in pgp" => @user.family_survey_response.relatives_interested_in_pgp,
        "Family Monozygotic twin" => @user.family_survey_response.monozygotic_twin,
        "Family Child situation" => @user.family_survey_response.child_situation,
        "Family Youngest child birth year" => @user.family_survey_response.youngest_child_birth_year,

        "Residency Us resident" => @user.residency_survey_response.us_resident,
        "Residency Country" => @user.residency_survey_response.country,
        "Residency Zip" => @user.residency_survey_response.zip,
        "Residency Can travel to boston" => @user.residency_survey_response.can_travel_to_boston,

        "Waitlist Count" => @user.waitlists.count,

        "Informed Consent Twin" => @user.informed_consent_response.twin,
        "Informed Consent Biopsy" => @user.informed_consent_response.biopsy,
        "Informed Consent Recontact" => @user.informed_consent_response.recontact,

        "Phr profile name" => @user.phr_profile_name,

        "Baseline traits survey Sex" => @user.baseline_traits_survey.sex,
        "Baseline traits survey Health insurance" => @user.baseline_traits_survey.health_insurance,
        "Baseline traits survey Health or medical conditions" => @user.baseline_traits_survey.health_or_medical_conditions,
        "Baseline traits survey Prescriptions in last year" => @user.baseline_traits_survey.prescriptions_in_last_year,
        "Baseline traits survey Allergies" => @user.baseline_traits_survey.allergies,
        "Baseline traits survey Asian" => @user.baseline_traits_survey.asian,
        "Baseline traits survey Black" => @user.baseline_traits_survey.black,
        "Baseline traits survey Hispanic" => @user.baseline_traits_survey.hispanic,
        "Baseline traits survey Native" => @user.baseline_traits_survey.native,
        "Baseline traits survey Pacific" => @user.baseline_traits_survey.pacific,
        "Baseline traits survey White" => @user.baseline_traits_survey.white,
        "Baseline traits survey Birth year" => @user.baseline_traits_survey.birth_year,
        "Baseline traits survey Us citizen" => @user.baseline_traits_survey.us_citizen,
        "Baseline traits survey Birth country" => @user.baseline_traits_survey.birth_country,
        "Baseline traits survey Paternal grandfather born in" => @user.baseline_traits_survey.paternal_grandfather_born_in,
        "Baseline traits survey Paternal grandmother born in" => @user.baseline_traits_survey.paternal_grandmother_born_in,
        "Baseline traits survey Maternal grandfather born in" => @user.baseline_traits_survey.maternal_grandfather_born_in,
        "Baseline traits survey Maternal grandmother born in" => @user.baseline_traits_survey.maternal_grandmother_born_in,

        "Distinctive traits" => @user.distinctive_traits.map { |trait| "#{trait.name} (#{trait.rating}/5)" }.join(", "),

        "Enrollment essay" => @user.enrollment_essay,

        "Enrollment application result Has sequence" => @user.has_sequence,
        "Enrollment application result Has sequence explanation" => @user.has_sequence_explanation,
        "Enrollment application result Family members passed exam" => @user.family_members_passed_exam,
      }

      header_cells = CSV.parse(@csv).first
      values_cells = CSV.parse(@csv).second

      values.each do |header, value|
        assert header_cells.include?(header), "Expected to see csv header '#{header}' but didn't"
      end

      values.each do |header, value|
        column = header_cells.index(header)
        value_cell = values_cells[column]
        assert_equal value.to_s, value_cell.to_s, "Expected to see value '#{value}' but got '#{value_cell}' at column #{column} (the '#{header}' cell).\nFull CSV:\n#{@csv.inspect}"
      end
    end
  end
end
