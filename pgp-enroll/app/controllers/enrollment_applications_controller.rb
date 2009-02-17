class EnrollmentApplicationsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('enrollment_application')
    current_user.complete_enrollment_step(step)
    flash[:notice] = 'Thank you for submitting your enrollment application.  You will be contacted by a PGP staff member regarding your application.'
    redirect_to root_path
  end
end
