class ScreeningSubmissionsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('screening_submission')
    current_user.complete_enrollment_step(step)
    PhaseCompletion.create(:user => current_user, :phase => 'screening') 
    redirect_to root_path
  end
end
