class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user)
  end

  # As requested by Jason Bobe in an email Feb 24
  # and http://skitch.com/pnome/bfyqe/activation-email-2
  # do not send activation email
  # def after_save(user)
  #   UserMailer.deliver_activation(user) if user.recently_activated?
  # end
end
