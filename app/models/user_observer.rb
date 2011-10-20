class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    begin
      UserMailer.signup_notification(user).deliver
    rescue Exception => e
      user.log("E-mail to #{user.email} failed: #{e.inspect()}")
    end
  end
end
