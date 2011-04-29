class EnrollmentApplicationResultsController < ApplicationController
  skip_before_filter :ensure_enrolled

end
