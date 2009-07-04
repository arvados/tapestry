class PhrsController < ApplicationController
  def show
  end

  def create
    step = EnrollmentStep.find_by_keyword('phr')
    if !params[:phr_profile_name].blank?
      current_user.update_attributes(:phr_profile_name => params[:phr_profile_name])
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = 'Please specify your PHR profile name.'
      render :action => :show
    end
  end
end
