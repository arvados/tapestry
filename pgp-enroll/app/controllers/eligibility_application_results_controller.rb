class EligibilityApplicationResultsController < ApplicationController
  def index
    @has_sequence               = current_user.has_sequence
    @has_sequence_explanation   = current_user.has_sequence_explanation
    @family_members_passed_exam = current_user.family_members_passed_exam
  end

  def create
    current_user.has_sequence = params[:has_sequence]
    current_user.has_sequence_explanation = params[:has_sequence_explanation]
    current_user.family_members_passed_exam = params[:family_members_passed_exam]
    current_user.save
    flash[:notice] = "Thank you for your additional notes.  We will review your application and contact you as soon as possible."
    redirect_to eligibility_application_results_url
  end
end
