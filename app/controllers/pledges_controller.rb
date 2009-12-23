class PledgesController < ApplicationController
  def show
  end

  def create
    if params[:pledge] =~ /[0-9\.]+/ && params[:pledge].to_f >= 0 && current_user.update_attribute(:pledge, params[:pledge])
      step = EnrollmentStep.find_by_keyword('pledge')
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      flash[:error] = 'You should make a pledge in number of US dollars.'
      show
      render :action => 'show'
    end
  end
end
