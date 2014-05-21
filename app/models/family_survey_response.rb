class FamilySurveyResponse < ActiveRecord::Base
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
        user.save(:validate => false)
      end

      step = EnrollmentStep.find_by_keyword('screening_surveys')
      user.complete_enrollment_step(step)
    end
  end

  RELATIVES_INTERESTED_IN_PGP_VALUES = %w(0 1 2 3+)

  MONOZYGOTIC_TWIN_OPTIONS = {
    'No, I do not have a monozygotic twin.'                                 => 'no',
    'Yes and he/she is willing to participate in this research study.'      => 'willing',
    'Yes, but he/she is not willing to participate in this research study.' => 'unwilling',
    "I don't know"                                                          => 'unknown'
  }

  CHILD_SITUATION_OPTIONS = {
    'I have one or more children.'                                                                      => 'some',
    'I do not currently have children, but I plan to have children or may have children in the future.' => 'none',
    'I do not currently have children and I do not plan to have children.'                              => 'never',
    "I don't know"                                                                                      => 'unknown'
  }

  belongs_to :user

  validates_presence_of :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

  validates_inclusion_of :birth_year,                  :in => 1895..3000,                          :message => 'must be answered'
  validates_inclusion_of :relatives_interested_in_pgp, :in => RELATIVES_INTERESTED_IN_PGP_VALUES,  :message => 'must be answered'
  validates_inclusion_of :monozygotic_twin,            :in => MONOZYGOTIC_TWIN_OPTIONS.values,     :message => 'must be answered'
  validates_inclusion_of :child_situation,             :in => CHILD_SITUATION_OPTIONS.values,      :message => 'must be answered'
  validates_inclusion_of :youngest_child_birth_year,   :in => 1895..3000, :if => :youngest_child_birth_year?, :message => 'must be filled out if you have children'

  validate :youngest_child_birth_year_required_if_you_have_children

  def eligible?
    maximum_age = Time.now.year - birth_year
    possibly_under_21 = maximum_age < 21
    unwilling_monozygotic_twin = ( monozygotic_twin == 'unwilling' )

    return !possibly_under_21 && !unwilling_monozygotic_twin
  end

  def waitlist_message
    I18n.t 'messages.waitlist.family'
  end

  private

  def youngest_child_birth_year_required_if_you_have_children
    if self.child_situation == 'some' && self.youngest_child_birth_year.nil?
      errors.add(:youngest_child_birth_year, "must be filled out if you have children.")
    end
  end

end
