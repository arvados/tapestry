class TraitCollectionsController < ApplicationController
  def show
  end

  def create
    current_user.phr = params[:phr]

    if current_user.save && current_user.reload.phr && current_user.reload.phr.exists?
      step = EnrollmentStep.find_by_keyword('trait_collection')
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = "You must upload a valid CCR file containing your personal health record to proceed."
      show
      render :action => 'show'
    end
  end
end
