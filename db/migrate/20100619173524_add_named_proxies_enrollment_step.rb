class AddNamedProxiesEnrollmentStep < ActiveRecord::Migration
  def self.up
    # Insert a new step to allow people to name proxies
    execute "INSERT INTO enrollment_steps (keyword, ordinal, title, description, duration) values ('named_proxies',8,'Name Designated Proxies','Name Designated Proxies','5 minutes')"
  end

  def self.down
    # Remove name proxies step
    execute "DELETE FROM enrollment_steps where ordinal=8"
  end
end
