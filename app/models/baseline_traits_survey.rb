class BaselineTraitsSurvey < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  validates_inclusion_of :us_citizen, :in => [true, false], :message => "can't be blank"
  validates_inclusion_of :health_insurance, :in => [true, false], :message => "can't be blank"
  validates_inclusion_of :health_or_medical_conditions, :in => [true, false], :message => "can't be blank"
  validates_inclusion_of :prescriptions_in_last_year, :in => [true, false], :message => "can't be blank"
  validates_inclusion_of :allergies, :in => [true, false], :message => "can't be blank"

  validates_presence_of :sex,
                        :birth_country,
                        :paternal_grandfather_born_in,
                        :paternal_grandmother_born_in,
                        :maternal_grandfather_born_in,
                        :maternal_grandmother_born_in
end
