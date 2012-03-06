class AddUploadTosConsentToGeneticData < ActiveRecord::Migration
  def self.up
    add_column :genetic_data, :upload_tos_consent, :boolean
    update "update genetic_data set upload_tos_consent='1'";
  end

  def self.down
    remove_column :genetic_data, :upload_tos_consent
  end
end
