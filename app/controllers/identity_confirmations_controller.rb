class IdentityConfirmationsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def show
  end

  def create
    if params[:identity_confirmation].blank? ||
       params[:identity_confirmation][:address1].blank? ||
       params[:identity_confirmation][:city].blank? ||
       params[:identity_confirmation][:state].blank? ||
       params[:identity_confirmation][:zip].blank?
      flash[:error] = 'You must enter your mailing address to confirm your identity.'
      render :action => 'show'
    else
      current_user.update_attributes(params[:identity_confirmation])
      step = EnrollmentStep.find_by_keyword('identity_confirmation')
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    end
  end
end
