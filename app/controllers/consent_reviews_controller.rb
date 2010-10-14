class ConsentReviewsController < ApplicationController
  def show
  end

  def create
    if params[:consent_review] && (params[:consent_review][:agreement] == "1")
      step = EnrollmentStep.find_by_keyword('consent_review')
      current_user.log('Reviewed full consent form version ' + LATEST_CONSENT_VERSION,step)
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = 'You must review the PGP Consent Form before proceeding.'
      render :action => 'show'
    end
  end
end
