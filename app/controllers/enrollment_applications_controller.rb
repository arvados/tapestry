class EnrollmentApplicationsController < ApplicationController
  def show
  end

  def create
    if params[:essay].blank? || params[:essay].split.size < 20 || params[:essay].split.size > 200
      flash[:error] = "You must submit an essay 20&ndash;200 words."
      show
      render :action => 'show'
    else
      current_user.update_attribute(:enrollment_essay, params[:essay])
      step = EnrollmentStep.find_by_keyword('enrollment_application')
      current_user.complete_enrollment_step(step)
      flash[:notice] = 'Thank you for submitting your enrollment application.  You will be contacted by a PGP staff member regarding your application.'
      redirect_to root_path
    end
  end
end
