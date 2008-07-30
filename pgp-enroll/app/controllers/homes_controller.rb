class HomesController < ApplicationController
  def index
    @steps = EnrollmentStep.find :all, :order => 'ordinal'
    @next_step = current_user ? current_user.next_enrollment_step : EnrollmentStep.find_by_keyword('signup')
  end
end
