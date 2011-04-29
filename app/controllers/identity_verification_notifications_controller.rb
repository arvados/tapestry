class IdentityVerificationNotificationsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def done
     step = EnrollmentStep.find_by_keyword('identity_verification_notification')
     current_user.complete_enrollment_step(step)
     redirect_to root_path
  end

end
