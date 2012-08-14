class SafetyQuestionnaire < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  belongs_to :user

  validates :user_id, :datetime, :presence => true
  validate :must_choose_has_changes_value
  validate :must_add_comments_if_reporting_changes

  def must_choose_has_changes_value
    # Sigh, not using validates :has_changes, :inclusion => { :in => [ true, false ], :message => '...' } because that way we can't omit the mention of 'has_changes', the field name. 
    if has_changes.nil? or (has_changes != true and has_changes != false) then
      errors.add(:base,"Please indicate if you would like to report changes to the PGP.")
    end
  end

  def must_add_comments_if_reporting_changes
    if has_changes and events == '' and reactions == '' and contact == '' and healthcare == '' then
      errors.add(:base,"If you would like to report changes to the PGP, please add a comment to one or more of the questions. Otherwise, please select 'No, I would like to report no changes to the PGP.' in question 1.")
    end
  end

end
