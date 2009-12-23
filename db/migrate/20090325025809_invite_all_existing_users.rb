class User < ActiveRecord::Base
end

class InvitedEmail < ActiveRecord::Base
end

class InviteAllExistingUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      InvitedEmail.create(:email => user.email, :accepted_at => user.created_at)
    end
  end

  def self.down
  end
end
