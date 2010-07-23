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
    begin
      unless current_user.authsub_token.blank?
        ccr_list = Dir.glob(get_ccr_path(current_user.id) + '*').reverse
        if ccr_list.length > 0
          feed = File.new(ccr_list[0])
          ccr = Nokogiri::XML(feed)
	  etag = CGI.unescapeHTML(ccr.root.xpath('@gd:etag').inner_text)
          begin
	    result = get_ccr(current_user, etag)
	    ccr = Nokogiri::XML(result)
            updated = ccr.xpath('/xmlns:feed/xmlns:updated').inner_text
            ccr_filename = get_ccr_filename(current_user.id, true, updated)
	    if !File.exist?(ccr_filename)
              outFile = File.new(ccr_filename, 'w')
      	      outFile.write(ccr)
      	      outFile.close
	    end
	  rescue
	  end  
	end
      end
    rescue
	flash[:error] = 'Could not update your PHR. Please try refreshing it manually'
    end
  end
end
