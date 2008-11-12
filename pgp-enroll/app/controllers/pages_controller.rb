class PagesController < ApplicationController

  PAGE_KEYWORDS = %w(logged_out introduction home)

  before_filter :ensure_valid
  helper_method :total_user_count, :recent_students, :recent_sponsors, :recent_causes
  skip_before_filter :login_required, :only => [:show]

  def show
    fetch_ivars
    render :template => current_page
  end

  protected

  def ensure_valid
    unless template_exists?(current_page)
      raise ActionController::RoutingError,
            "No such static page: #{current_page.inspect}"
    end
  end

  def current_page
    "pages/#{params[:id].to_s.downcase}"
  end

  # TODO: Refactor
  def fetch_ivars
    @steps            = EnrollmentStep.find :all, :order => 'ordinal'
    @step_completions = current_user ? current_user.enrollment_step_completions : []
    @next_step        = current_user ? current_user.next_enrollment_step : []
  end

end
