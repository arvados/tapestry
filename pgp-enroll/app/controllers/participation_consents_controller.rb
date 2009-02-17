class ParticipationConsentsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('participation_consent')
    current_user.complete_enrollment_step(step)
    redirect_to root_path
  end
end
