class InformedConsentResponse < ActiveRecord::Base
  belongs_to :user

  attr_protected :user_id
  validates_presence_of :user_id
  validates_inclusion_of :twin,      :in => [true, false], :message => 'must be Yes or No'
  validates_inclusion_of :biopsy,    :in => [true, false], :message => 'must be Yes or No'
  validates_inclusion_of :recontact, :in => [true, false], :message => 'must be Yes or No'
end
