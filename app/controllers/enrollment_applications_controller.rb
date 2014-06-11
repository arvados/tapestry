class EnrollmentApplicationsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('enrollment_application')
    current_user.complete_enrollment_step(step)
    UserMailer.enrollment_submitted_notification(current_user).deliver if APP_CONFIG['email_enrollment_submitted_notification']
    flash[:notice] = 'Thank you for submitting your enrollment application.'
    redirect_to root_path
  end
end
