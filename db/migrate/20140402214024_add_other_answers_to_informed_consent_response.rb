class AddOtherAnswersToInformedConsentResponse < ActiveRecord::Migration
  def self.up
    add_column :informed_consent_responses, :other_answers, :text
  end

  def self.down
    remove_column :informed_consent_responses, :other_answers
  end
end
