class UserMailer < ActionMailer::Base

  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{ROOT_URL}/activate/#{user.activation_code}"
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{ROOT_URL}/"
  end

  def delete_request(user)
    setup_email(user)
    @recipients  = "delete-account@personalgenomes.org"
    @subject     = "PGP account delete request"
    @body[:url]  = "http://#{ROOT_URL}/admin/users"
    @body[:user] = user
  end

  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "#{ADMIN_EMAIL}"
    @subject     = "[#{ROOT_URL}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
