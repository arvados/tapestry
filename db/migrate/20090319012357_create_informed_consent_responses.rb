class CreateInformedConsentResponses < ActiveRecord::Migration
  def self.up
    create_table :informed_consent_responses do |t|
      t.boolean 'twin', :null => false, :default => false
      t.boolean 'biopsy', :null => false, :default => false
      t.boolean 'recontact', :null => false, :default => false

      t.references 'user'

      t.timestamps
    end
  end

  def self.down
    drop_table :informed_consent_responses
  end
end
