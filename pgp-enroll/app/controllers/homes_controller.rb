class HomesController < ApplicationController
  skip_before_filter :login_required, :only => [:index]

  def index
    if current_user
      @steps = EnrollmentStep.find :all, :order => 'ordinal'
      @step_completions = current_user.enrollment_step_completions
      @next_step = current_user.next_enrollment_step
    end
  end
end
