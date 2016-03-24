class UserMailer < ActionMailer::Base

  def dataset_notification_message(url,user,dataset)
    setup_email(user)
    @subject += 'Please review your new specimen analysis data'
    @body[:url] = url
    @body[:dataset] = dataset
  end

  def support_message(message,user)
    @message = message
    @user = user
    headers['X-PGP-Unique-Hash'] = user.unique_hash
    headers['X-PGP-Detected-Browser'] = message.env['HTTP_USER_AGENT']
    mail(:from => message.email,
         :to => SUPPORT_EMAIL,
         :subject => "#{message.category}: #{message.subject}")
  end

  def bulk_message(bulk_message,recipient)
    @message = bulk_message.body
    mail(:from => SUPPORT_EMAIL,
         :to => recipient.email,
         :subject => "#{bulk_message.subject}")
  end

  def signup_notification(user)
    @url  = "#{ROOT_URL_SCHEME}#{ROOT_URL}/activate/#{user.activation_code}"
    @user = user
    @recipient = user.email
    @recipient = SEND_ALL_USER_EMAIL_TO if defined? SEND_ALL_USER_EMAIL_TO
    mail(:from => ADMIN_EMAIL,
         :to => @recipient,
         :subject => 'Please activate your new account')
  end

  def error_notification(user,message)
    @user = user
    if @user.nil? then
      @user = User.new()
      @user.first_name = 'Anonymous'
      @user.last_name = 'user'
    end
    @message = message
    mail(:from => SYSTEM_EMAIL,
         :to => SYSTEM_EMAIL,
         :subject => "Critical error at #{ROOT_URL}")
  end

  def delete_request(user)
    setup_email(user)
    if defined? WITHDRAWAL_NOTIFICATION_EMAIL
      @recipients = "#{WITHDRAWAL_NOTIFICATION_EMAIL}"
    else
      @recipients = "#{ADMIN_EMAIL}"
    end
    @subject     = "PGP account deletion request"
    @body[:url]  = "#{ROOT_URL_SCHEME}#{ROOT_URL}/admin/users"
    user.log("PGP account deletion request")
  end

  def password_reset(user)
    setup_email(user)
    @subject    += 'Reset your password'
    @body[:url]  = "#{ROOT_URL_SCHEME}#{ROOT_URL}/password/edit?id=#{user.id}&key=#{user.crypted_password}"
    user.log("Sent password reset link: #{@body[:url]}")
  end

  def email_change_notification(user, old_email)
    setup_email(user)
    @subject += 'Email address changed'
    @recipients = old_email unless defined? SEND_ALL_USER_EMAIL_TO
    @body[:old_email] = old_email
    user.log("Sent email change notification") unless user.id.nil? # (preview)
  end

  def family_relation_notification(family_relation)
    setup_email(family_relation.relative)
    @subject += 'You have been added as a family member'
    @family_relation = family_relation
    @body[:url] = "#{ROOT_URL_SCHEME}#{ROOT_URL}/family_relations"
    @body[:login_url]  = "#{ROOT_URL_SCHEME}#{ROOT_URL}/login"
    family_relation.relative.log("Sent family relation notification: added as a family member (#{@family_relation.relation}) by #{@family_relation.user.hex}")
  end

  def family_relation_rejection(family_relation)
    setup_email(family_relation.user)
    @subject += 'Your family relation request was rejected'
    @body[:user] = family_relation.relative
    family_relation.user.log("Sent family relation notification: family relation request was rejected by #{family_relation.relative.hex}")
  end

  def family_relation_deletion(family_relation)
    setup_email(family_relation.user)
    @subject += 'Your family relation was deleted'
    @body[:user] = family_relation.relative
    family_relation.user.log("Sent family relation notification: family relation was deleted by #{family_relation.relative.hex} (#{FamilyRelation::relations[family_relation.relation]})")
  end

  def safety_questionnaire_reminder(user)
    setup_email(user)
    @subject += 'PGP Safety Questionnaire'
    # DO NOT modify the user.log line below without also modifying script/send_safety_questionnaire_reminders.rb which depends on it!
    user.log("Sent Safety Questionnaire Reminder")
  end

  def enrollment_decision_notification(user)
    setup_email(user)
    @subject += 'PGP Enrollment decision'
    user.log("Sent PGP Enrollment decision notification")
  end

  def enrollment_submitted_notification(user)
    setup_email(user)
    @subject += 'PGP Enrollment Submitted'
    user.log("Sent PGP Enrollment Submitted notification")
  end

  def withdrawal_notification(user)
    setup_email(user)
    @subject += 'PGP withdrawal'
    user.log("Sent PGP withdrawal notification")
  end

  def withdrawal_staff_notification(user)
    setup_email(user)
    if defined? WITHDRAWAL_NOTIFICATION_EMAIL
      @recipients = "#{WITHDRAWAL_NOTIFICATION_EMAIL}"
    else
      @recipients = "#{ADMIN_EMAIL}"
    end
    @subject += 'PGP withdrawal'
  end

  def kit_sent_notification(study_participant, sp_info)
    setup_email(study_participant.user)
    @study_participant = study_participant
    @study = study_participant.study
    @sp_info = sp_info
    @subject += "Specimen collection kit: #{@study.name}"
  end

  def kit_received_notification(participant, researcher, kit)
    setup_email(participant)
    @researcher = researcher
    @kit = kit
    @subject += "Received kit \"#{@kit.name}\""
  end

  def unclaimed_kit_reminder(study_participant)
    setup_email(study_participant.user)
    @study_participant = study_participant
    @study = study_participant.study
    @subject += "Reminder: specimen collection kit"
  end

  def unreturned_kit_reminder(study_participant, kit)
    setup_email(study_participant.user)
    @study_participant = study_participant
    @study = study_participant.study
    @kit = kit
    @subject += "Reminder: specimen collection kit"
  end

  def arvados_job_failure(job)
    @recipients = ADMIN_EMAIL
    @from       = ADMIN_EMAIL
    @subject    = "[#{ROOT_URL}] Arvados job failed"
    @sent_on    = Time.now
    @job        = job
  end

  protected

  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "#{ADMIN_EMAIL}"
    @subject     = "[#{ROOT_URL}] "
    @sent_on     = Time.now
    @body[:user] = user
    @recipients = SEND_ALL_USER_EMAIL_TO if defined? SEND_ALL_USER_EMAIL_TO
  end
end
