class ParticipationConsentsController < ApplicationController
  def show
  end

  def create
    if params[:participation_consent][:name] == current_user.full_name &&
       params[:participation_consent][:email] == current_user.email
      step = EnrollmentStep.find_by_keyword('participation_consent')
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = 'Your name and email signature must match the name and email that you signed up with.'
      show
      render :action => 'show'
    end
  end
end
