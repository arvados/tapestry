# Pushed SQL queries here from user.rb to make main model more readable
# This could be cleaned up.
module UserEligibilityGroupings
  def self.eligibility_group_sql(group)
     raise "Undefined screening eligibility group (only 1-3 are defined)" unless [1,2,3].include?(group)
     eligibility_group_sql_array[group - 1]
   end

  def self.eligibility_group_sql_array
    [
      "
      residency_survey_responses.resident = 1 and
      residency_survey_responses.can_travel_to_pgphq = 1 and
      family_survey_responses.birth_year <= :birth_year and
      enrollment_step_completions.enrollment_step_id = :eligibility_step_id and
      (
       family_survey_responses.monozygotic_twin = 'no' or
       family_survey_responses.monozygotic_twin = 'willing'
      ) and
      (
       privacy_survey_responses.worrisome_information_comfort_level = 'always' or
       privacy_survey_responses.worrisome_information_comfort_level = 'understand'
      ) and
      (
       privacy_survey_responses.information_disclosure_comfort_level = 'comfortable' or
       privacy_survey_responses.information_disclosure_comfort_level = 'understand'
      ) and
      (
       privacy_survey_responses.past_genetic_test_participation = 'public' or
       privacy_survey_responses.past_genetic_test_participation = 'yes' or
       privacy_survey_responses.past_genetic_test_participation = 'no' or
       privacy_survey_responses.past_genetic_test_participation = 'unsure'
      )
      ",

      "
      residency_survey_responses.resident = 1 and
      residency_survey_responses.can_travel_to_pgphq = 1 and
      family_survey_responses.birth_year <= :birth_year and
      enrollment_step_completions.enrollment_step_id = :eligibility_step_id and
      (
        family_survey_responses.monozygotic_twin = 'no' or
        family_survey_responses.monozygotic_twin = 'willing'
      ) and
      (
        (
          privacy_survey_responses.worrisome_information_comfort_level = 'depends' or
          privacy_survey_responses.worrisome_information_comfort_level = 'uncomfortable'
        ) or
        (
          privacy_survey_responses.information_disclosure_comfort_level = 'uncomfortable' or
          privacy_survey_responses.information_disclosure_comfort_level = 'depends' or
          privacy_survey_responses.information_disclosure_comfort_level = 'unsure'
        ) or
        (
          privacy_survey_responses.past_genetic_test_participation = 'confidential'
        )
      )
      ",

      "
       enrollment_step_completions.enrollment_step_id = :eligibility_step_id and
       (
         residency_survey_responses.resident = 0 or
         residency_survey_responses.can_travel_to_pgphq = 0 or
         family_survey_responses.birth_year > :birth_year or
         family_survey_responses.monozygotic_twin = 'unwilling' or
         family_survey_responses.monozygotic_twin = 'unknown'
       )
       "
    ]
  end
end
