class ScreeningSurveyResponse < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  after_save :complete_enrollment_step
  attr_protected :user_id

  scope :monozygotic_ok, where("monozygotic_twin in ('no','willing')")
  scope :worrisome_ok, where("worrisome_information_comfort_level in ('always','understand')")
  scope :information_disclosure_ok, where("information_disclosure_comfort_level in ('comfortable','understand')")
  scope :past_genetic_test_ok, where("past_genetic_test_participation in ('no','public','unsure_public')")
  scope :us_citizen_or_resident, where("us_citizen_or_resident is true")
  scope :age_majority, where("age_majority is true")

  validates :twin_name, :presence => true, :if => Proc.new {|ssr| ssr.monozygotic_twin == 'willing' }
  validates :twin_email, :presence => true, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, :if => Proc.new {|ssr| ssr.monozygotic_twin == 'willing' }

  scope :passed, monozygotic_ok.worrisome_ok.information_disclosure_ok.past_genetic_test_ok.us_citizen_or_resident.age_majority

  scope :failed, where("monozygotic_twin not in ('no','willing') or
                        worrisome_information_comfort_level not in ('always','understand') or
                        information_disclosure_comfort_level not in ('comfortable','understand') or
                        past_genetic_test_participation not in ('no','public','unsure_public') or
                        us_citizen_or_resident is not true or
                        age_majority is not true")

  def passed?
    ScreeningSurveyResponse.passed.where('id = ?',self.id).size > 0
  end

  def complete_results_enrollment_step_if_passed
    if self.passed? then
      step = EnrollmentStep.find_by_keyword('screening_survey_results')
      user.complete_enrollment_step(step)
    end
  end

  def complete_enrollment_step
    user = self.user.reload
    if not user.screening_survey_response.us_citizen_or_resident.nil? and
       not user.screening_survey_response.age_majority.nil? and
       not user.screening_survey_response.monozygotic_twin.nil? and
       not user.screening_survey_response.worrisome_information_comfort_level.nil? and
       not user.screening_survey_response.information_disclosure_comfort_level.nil? and
       not user.screening_survey_response.past_genetic_test_participation.nil? then

      if not user.eligibility_survey_version or user.eligibility_survey_version == 'v1' then
        user.eligibility_survey_version = 'v2'
        user.save(:validate => false)
      end

      step = EnrollmentStep.find_by_keyword('screening_surveys')
      user.complete_enrollment_step(step)
      if not user.screening_survey_response.passed? then
        user.log('Failed Eligibility Questionnaire: ' + user.ineligible_for_enrollment.delete_if{ |x| x == 'Enrollment application not submitted'}.join(', '),step)
      else
        user.log('Passed Eligibility Questionnaire',step)
      end
    end
  end

  MONOZYGOTIC_TWIN_OPTIONS = {
    '0No, I do not have a living monozygotic twin.'                          => 'no',
    '1Yes and he/she is willing to participate in this research study.'      => 'willing',
    "2I don't know"                                                          => 'unknown',
    '3Yes, but he/she is not willing to participate in this research study.' => 'unwilling',
  }

  WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS = {
    '0It depends on the information. I would want to review any information about me on a case-by-case basis.' => 'depends',
    "1I don't find information about myself worrisome and would always want to know." => 'always',
    '2Unsure.' => 'unsure',
    '3I am very uncomfortable with the idea of learning potentially worrisome information about myself.' => 'uncomfortable',
    '4I understand the possibility exists that I will learn potentially worrisome information, but I am willing to accept those risks.' => 'understand',
  }

  INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS = {
    '0It depends, I would want to review any information on a case-by-case basis.' => 'depends',
    "1I don't find information about myself worrisome and I'm comfortable with others having access to this information as well." => 'comfortable',
    '2I understand there are potential risks, but I am willing to make my genomic, health and trait data publicly available anyway.' => 'understand',
    '3I am very uncomfortable with the idea of public access to my genomic, health and trait data. The potential risks are too great.' => 'uncomfortable',
    '4Unsure' => 'unsure',
  }

  PAST_GENETIC_TEST_PARTICIPATION_OPTIONS = {
    '0No.' => 'no',
    '1Yes, but I would prefer to keep this information confidential.' => 'confidential',
    '2Unsure, and if genetic information is available from other sources, I am willing to make this information publicly available.' => 'unsure_public',
    '3Unsure, and if genetic information is available from other sources I prefer to keep it confidential.' => 'unsure_confidential',
    "4Yes, and I am comfortable making this information publicly available." => 'public',
  }


  def eligible?
    us_citizen_or_resident
  end

  def waitlist_message
  end

end
