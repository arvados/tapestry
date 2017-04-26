class EligibilityScreeningResultsController < ApplicationController
  skip_before_filter :ensure_enrolled

  def index
  end
end
