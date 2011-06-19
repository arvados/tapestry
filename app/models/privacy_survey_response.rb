class PrivacySurveyResponse < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  after_save :complete_enrollment_step
  attr_protected :user_id
  def complete_enrollment_step
    user = self.user.reload
    if user.residency_survey_response &&
       user.family_survey_response &&
       user.privacy_survey_response

      if not user.eligibility_survey_version then
        user.eligibility_survey_version = 'v1'
        user.save(false)
      end

      step = EnrollmentStep.find_by_keyword('screening_surveys')
      user.complete_enrollment_step(step)
    end
  end

  WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS = {
    'I am very uncomfortable with the idea of learning potentially worrisome information about myself.' => 'uncomfortable',
    'I understand the possibility exists that I will learn potentially worrisome information, but I am willing to accept those risks.' => 'understand',
    'Unsure.' => 'unsure',
    "I don't find information about myself worrisome and would always want to know." => 'always',
    'It depends on the information. I would want to review any information about me on a case-by-case basis.' => 'depends'
  }

  INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS = {
    'I am very uncomfortable with the idea of public access to my genomic data. The potential risks are too great.' => 'uncomfortable',
    'I understand there are potential risks, but I am willing to make my genomic data publicly available anyway.' => 'understand',
    'Unsure' => 'unsure',
    "I don't find information about myself worrisome and I'm comfortable with others having access to this information as well." => 'comfortable',
    "It depends, I would want to review any information on a case-by-case basis." => 'depends'
  }

  PAST_GENETIC_TEST_PARTICIPATION_OPTIONS = {
    'Yes and if requested, I would share any information with the PGP.' => 'yes',
    'Yes, but I would prefer to keep this information confidential.' => 'confidential',
    'No.' => 'no',
    'Unsure' => 'unsure',
    "Yes, and I am comfortable making this information publicly available." => 'public'
  }

  belongs_to :user

  validates_inclusion_of :worrisome_information_comfort_level,
                         :in => WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS.values,
                         :message => 'must be answered'

  validates_inclusion_of :information_disclosure_comfort_level,
                         :in => INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS.values,
                         :message => 'must be answered'

  validates_inclusion_of :past_genetic_test_participation,
                         :in => PAST_GENETIC_TEST_PARTICIPATION_OPTIONS.values,
                         :message => 'must be answered'

  def eligible?
    eligible_worrisome_information_comfort_level  = %w(understand always).include?(worrisome_information_comfort_level)
    eligible_information_disclosure_comfort_level = %w(understand comfortable).include?(information_disclosure_comfort_level)
    eligible_past_genetic_test_participation      = %w(public).include?(past_genetic_test_participation)

    eligible_worrisome_information_comfort_level &&      eligible_information_disclosure_comfort_level &&      eligible_past_genetic_test_participation
  end

  def waitlist_message
    <<-EOS
    Thank you for your interest in participating in the PGP.
    You should be completely comfortable with your participation in the PGP,
    with any possible findings, and with sharing your information publicly
    before participation.
    EOS
  end
end
