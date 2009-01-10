class FamilySurveyResponse < ActiveRecord::Base
  validates_presence_of :birth_year, :relatives_interested_in_pgp, :monozygotic_twin, :child_situation

  validates_inclusion_of :birth_year,                  :in => 1895..3000,                          :message => 'is invalid'
  validates_inclusion_of :relatives_interested_in_pgp, :in => %w(0 1 2 3+),                        :message => 'is invalid'
  validates_inclusion_of :monozygotic_twin,            :in => %w(no yes-willing yes-unwilling),    :message => 'is invalid'
  validates_inclusion_of :child_situation,             :in => %w(some none never),                 :message => 'is invalid'
  validates_inclusion_of :youngest_child_age,          :in => 0..100, :if => :youngest_child_age?, :message => 'is invalid'
end
