class TraitCollectionsController < ApplicationController
  def show
    @baseline_traits_survey = current_user.baseline_traits_survey || BaselineTraitsSurvey.new(
      :birth_country => 'United States',
      :paternal_grandfather_born_in => 'United States',
      :paternal_grandmother_born_in => 'United States',
      :maternal_grandfather_born_in => 'United States',
      :maternal_grandmother_born_in => 'United States')
  end

  def create
    @baseline_traits_survey = BaselineTraitsSurvey.new(params[:baseline_traits_survey])
    @baseline_traits_survey.user = current_user

    if @baseline_traits_survey.save
      step = EnrollmentStep.find_by_keyword('trait_collection')
      current_user.complete_enrollment_step(step)
      flash[:notice] = 'You have completed the baseline trait collection survey.'
      redirect_to root_path
    else
      render :action => 'show'
    end
  end
end
