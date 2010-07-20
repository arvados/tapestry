# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  include PhrccrsHelper
  skip_before_filter :login_required, :only => [:new, :create]

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
    flash[:error] = "Couldn't log you in as '#{params[:email]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def update_ccr_if_exists
    unless current_user.authsub_token.blank?
      ccr_path = get_ccr_filename(current_user.id, false)
      if File.exist?(ccr_path)
    	begin
      	  feed = get_ccr(current_user)
          outFile = File.new(get_ccr_filename(current_user.id), 'w')
      	  outFile.write(feed)
      	  outFile.close
    	rescue
      	  flash[:error] = 'There was an error updating your PHR.'
        end
      end
    end
  end
end
