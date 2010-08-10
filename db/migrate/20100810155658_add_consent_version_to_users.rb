class AddConsentVersionToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :consent_version, :string
    self.set_consent_version
  end

  def self.set_consent_version
    execute 'UPDATE users u set consent_version=\'20090324\' where id in (select user_id from enrollment_step_completions where user_id=u.id and enrollment_step_id=5 and created_at < \'2010-07-01 00:00:00\')'
    execute 'UPDATE users u set consent_version=\'20100331\' where id in (select user_id from enrollment_step_completions where user_id=u.id and enrollment_step_id=5 and created_at > \'2010-07-01 00:00:00\')'
  end

  def self.down
    remove_column :users, :consent_version
  end

end
