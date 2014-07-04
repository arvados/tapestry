class DistinctiveTraitsSurveysController < ApplicationController
  def show
  end

  def create
    current_user.distinctive_traits.destroy_all
    if params[:traits]
      traits = params[:traits].map do |trait_attributes|
        trait = current_user.distinctive_traits.build(trait_attributes)

        if !trait.valid?
          current_user.distinctive_traits.delete(trait)
        end
      end
      current_user.save
    end

    complete_this_enrollment_step
    set_the_flash
    redirect_to root_url
  end

  private

  def complete_this_enrollment_step
    step = EnrollmentStep.find_by_keyword('distinctive_traits_survey')
    current_user.complete_enrollment_step(step)
  end

  def set_the_flash
    if current_user.distinctive_traits.any?
      flash[:notice] = 'Your distinctive traits were recorded.'
    else
      flash[:error] = 'No distinctive traits were recorded.'
    end
  end
end
