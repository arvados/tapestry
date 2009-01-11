class PrivacySurveyResponse < ActiveRecord::Base
  WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS = {
    'I am very uncomfortable with the idea of learning potentially worrisome information about myself.' => 'uncomfortable',
    'I understand the possibility exists that I will learn potentially worrisome information, but I am willing to accept those risks.' => 'comfortable'
  }

  INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS = {
    'I am very uncomfortable with the idea of public access to my genomic data. The potential risks are too great.' => 'uncomfortable',
    'I understand there are potential risks. But I am willing to make my genomic data publicly available anyway.' => 'comfortable',
    'Unsure' => 'unsure'
  }

  PAST_GENETIC_TEST_PARTICIPATION_OPTIONS = {
    'Yes and if requested, I would should share any information with the PGP.' => 'yes',
    'Yes, but I would prefer to keep this information confidential.' => 'confidential',
    'No.' => 'no'
  }

  belongs_to :user

  validates_inclusion_of :worrisome_information_comfort_level,
                         :in => WORRISOME_INFORMATION_COMFORT_LEVEL_OPTIONS.values,
                         :message => 'is invalid'

  validates_inclusion_of :information_disclosure_comfort_level,
                         :in => INFORMATION_DISCLOSURE_COMFORT_LEVEL_OPTIONS.values,
                         :message => 'is invalid'

  validates_inclusion_of :past_genetic_test_participation,
                         :in => PAST_GENETIC_TEST_PARTICIPATION_OPTIONS.values,
                         :message => 'is invalid'
end
