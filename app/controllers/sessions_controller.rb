# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  include PhrccrsHelper
  skip_before_filter :login_required, :only => [:new, :create]
  # Allow user to log out when they have not 
  # * agreed to the TOS yet
  # * taken latest consent yet
  # * taken safety questionnaire yet
  skip_before_filter :ensure_tos_agreement, :only => [:destroy]
  skip_before_filter :ensure_latest_consent, :only => [:destroy]
  skip_before_filter :ensure_recent_safety_questionnaire, :only => [:destroy]

  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
      update_ccr_if_exists
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default page_url(:logged_out)
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{CGI.escapeHTML(params[:email])}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def update_ccr_if_exists
    begin
      unless current_user.authsub_token.blank?
        ccr_list = Dir.glob(get_ccr_path(current_user.id) + '*').reverse
        if ccr_list.length > 0
          server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"
          begin
            out = server.get_ccr(current_user.id, current_user.authsub_token, nil, ccr_profile_url)
          rescue Exception => e
            current_user.log("DRB server error when trying to update CCR: #{e.exception}",nil,nil,'Error requesting PHR update.')
          end
        end
      end
    end
  end
end
