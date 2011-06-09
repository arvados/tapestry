class SystemMailer < ActionMailer::Base
  
  def error_notification(subject,message)
    setup_email()
    @subject += 'ERROR: ' + subject
    @body[:message] = message
  end

  protected

  def setup_email()
    @recipients  = "#{SYSTEM_EMAIL}"
    @from        = "#{SYSTEM_EMAIL}"
    @subject     = "[#{ROOT_URL}] "
    @sent_on     = Time.now
  end

end
