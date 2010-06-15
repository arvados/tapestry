class AlterInformedConsentResponses < ActiveRecord::Migration
  def self.up
    execute "alter table informed_consent_responses modify twin tinyint default null"
    execute "alter table informed_consent_responses modify recontact tinyint default null"
    execute "alter table informed_consent_responses modify biopsy tinyint default null"
  end

  def self.down
    execute "alter table informed_consent_responses modify twin tinyint not null default 0"
    execute "alter table informed_consent_responses modify recontact tinyint not null default 0"
    execute "alter table informed_consent_responses modify biopsy tinyint not null default 0"
  end
end
