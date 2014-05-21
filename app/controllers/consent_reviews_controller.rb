class ConsentReviewsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def show
  end

  def create
    if params[:consent_review] && (params[:consent_review][:agreement] == "1")
      step = EnrollmentStep.find_by_keyword('consent_review')
      current_user.log('Reviewed full consent form version ' + LATEST_CONSENT_VERSION,step)
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = t('messages.review_consent_error')
      render :action => 'show'
    end
  end
end
