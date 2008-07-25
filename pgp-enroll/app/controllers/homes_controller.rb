class HomesController < ApplicationController
  def index
    @enrollment_steps = EnrollmentStep.find :all, :order => 'ordinal'
  end
end
