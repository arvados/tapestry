class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.signup_notification(user).deliver
  end
end
