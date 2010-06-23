class IdentityVerificationNotificationsController < ApplicationController

  def done
     step = EnrollmentStep.find_by_keyword('identity_verification_notification')
     current_user.complete_enrollment_step(step)
     redirect_to root_path
  end

end
