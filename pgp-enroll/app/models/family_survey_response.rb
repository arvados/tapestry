class FamilySurveyResponse < ActiveRecord::Base
  RELATIVES_INTERESTED_IN_PGP_VALUES = %w(0 1 2 3+)

  MONOZYGOTIC_TWIN_OPTIONS = {
    'No, I do not have a monozygotic twin.'                                 => 'no',
    'Yes and he/she is willing to participate in this research study.'      => 'willing',
    'Yes, but he/she is not willing to participate in this research study.' => 'unwilling'
  }

  CHILD_SITUATION_OPTIONS = {
    'I have one or more children. (Go to next question)'                                                => 'some',
    'I do not currently have children, but I plan to have children or may have children in the future.' => 'none',
    'I do not currently have children or I do not plan to have children.'                               => 'never'
  }

  belongs_to :user

  validates_presence_of :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

  validates_inclusion_of :birth_year,                  :in => 1895..3000,                          :message => 'must be answered'
  validates_inclusion_of :relatives_interested_in_pgp, :in => RELATIVES_INTERESTED_IN_PGP_VALUES,  :message => 'must be answered'
  validates_inclusion_of :monozygotic_twin,            :in => MONOZYGOTIC_TWIN_OPTIONS.values,     :message => 'must be answered'
  validates_inclusion_of :child_situation,             :in => CHILD_SITUATION_OPTIONS.values,      :message => 'must be answered'
  validates_inclusion_of :youngest_child_age,          :in => 0..100, :if => :youngest_child_age?, :message => 'must be answered'

  validate :youngest_child_age_required_if_you_have_children

  def eligible?
    maximum_age = Time.now.year - birth_year
    possibly_under_18 = maximum_age < 18
    unwilling_monozygotic_twin = ( monozygotic_twin == 'unwilling' )

    return !possibly_under_18 && !unwilling_monozygotic_twin
  end

  private

  def youngest_child_age_required_if_you_have_children
    if self.child_situation == 'some' && self.youngest_child_age.nil?
      errors.add(:youngest_child_age, "must be filled out if you have children.")
    end
  end

end
