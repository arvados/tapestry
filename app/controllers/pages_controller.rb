class PagesController < ApplicationController

  PAGE_KEYWORDS = %w(logged_out introduction home)

  before_filter :ensure_valid
  helper_method :total_user_count, :recent_students, :recent_sponsors, :recent_causes
  skip_before_filter :login_required, :only => [:show]

  def show
    if current_user and current_user.enrolled and not current_user.enrollment_accepted
      redirect_to enrollment_application_results_url
      return
    end

    @enrolled = User.enrolled.find(:all).sort{ |a,b| a.enrolled <=> b.enrolled }.paginate(:page => params[:page] || 1, :per_page => 100)

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
    if current_user
      @steps            = EnrollmentStep.ordered
      @step_completions = current_user.enrollment_step_completions
      @next_step        = current_user.next_enrollment_step
    else
      @steps            = []
      @step_completions = []
      @next_step        = nil
    end
  end

end
