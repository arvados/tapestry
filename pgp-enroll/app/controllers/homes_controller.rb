class HomesController < ApplicationController
  def index
    @steps = EnrollmentStep.find :all, :order => 'ordinal'
    @step_completions = current_user ? current_user.enrollment_step_completions : []
    @next_step = current_user ? current_user.next_enrollment_step : EnrollmentStep.find_by_keyword('signup')
  end
end
