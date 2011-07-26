class UserObserver < ActiveRecord::Observer
  observe :user

  def after_create(user)
    UserMailer.signup_notification(user).deliver
  end
end
