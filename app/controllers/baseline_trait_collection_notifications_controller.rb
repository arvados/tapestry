class BaselineTraitCollectionNotificationsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def done
     step = EnrollmentStep.find_by_keyword('baseline_trait_collection_notification')
     current_user.complete_enrollment_step(step)
     redirect_to root_path
  end

end
