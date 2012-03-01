class PhrccrsController < ApplicationController
  include PhrccrsHelper
  attr_accessor :ccr
  attr_accessor :outFile
  before_filter :store_location
  attr_accessor :processing_time
  attr_accessor :download_time

  def show
    @ccr_history = Ccr.find(:all, :conditions => {:user_id => current_user.id},
                            :order => 'version DESC')
  end

  def download
    @ccr = Ccr.find(params[:id])

    if @ccr.user_id != current_user.id then
      current_user.log("Attempt to download ccr (id #{@ccr.id}) owned by someone else (user id #{@ccr.user_id})")
      flash[:error] = "This CCR is not yours."
      redirect_to :action => :show
      return
    end

    ccr_path = get_ccr_path(current_user.id)
    ccr_filename = get_ccr_filename(current_user.id, false, @ccr.version)
    ccr_filename.gsub!(/^#{ccr_path}/,'')

    send_data(File.open(ccr_path + '/' + ccr_filename, "rb").read,
              :filename => ccr_filename,
              :disposition => 'attachment',
              :type => 'application/xml')
  end

  def review
    @ccr_history = Ccr.find(:all, :conditions => {:user_id => current_user.id},
                            :order => 'version DESC')

    version = params[:version]
    if version && !version.empty?
      for i in 0.. @ccr_history.length - 1 do
        if @ccr_history[i].version == version
          @current_version = version
          @ccr = @ccr_history[i]
          break
        end
      end
    elsif @ccr_history && @ccr_history.length > 0
      @current_version = @ccr_history[0].version
      @ccr = @ccr_history[0]
    end
  end

  def create
    commit_action = params[:commit]
    if commit_action.eql?('Link Profile')
      authsub()
    elsif commit_action.eql?('Unlink from Google Health')
      unlink_googlehealth(:action => :show)
    elsif commit_action.eql?('Review PHR')
      redirect_to :controller => 'phrccrs', :action => 'review'
    elsif commit_action.eql?('Refresh PHR')
      begin
        download_phr()
        flash[:notice] = 'Your PHR will be downloaded shortly; a request has been queued.'
      rescue Exception => e
        current_user.log("Error requesting PHR download: #{e.exception} #{e.inspect()}",nil,request.remote_ip,'Error requesting PHR download.')
        flash[:error] = 'There was an error requesting your PHR download. Please try again later.'
      end
      redirect_to :action => :review
    elsif params[:deleteccr]
      timestamp_regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{0,3})?Z$/
      timestamp = params[:deleteccr]
      if timestamp.scan(timestamp_regex).length > 0
        ccr_filename = get_ccr_filename(current_user.id, false, timestamp)
        if File.exists?(ccr_filename) then
          File.delete(ccr_filename)
          current_user.log("Deleted PHR (#{ccr_filename})")
          ccr_to_delete = Ccr.find(:first, :conditions => {:user_id => current_user.id, :version => timestamp })
          Ccr.destroy(ccr_to_delete.id)          
        else
          current_user.log("Unable to delete PHR (#{ccr_filename}): file not found")
        end
      end
      redirect_to :action => :review
    else
      redirect_to :action => :show
    end
  end

  def unlink_googlehealth(redirect = nil)
    begin
      authsub_revoke(current_user)
      current_user.log('Unlinked from Google Health')
      flash[:notice] = 'Unlinked from Google Health'
    rescue Exception => e
      current_user.log("Error unlinking from Google Health: #{e.exception}")
      flash[:error] = 'There was an error unlinking from your Google Health account.'
    end
    if !redirect
      redirect_to edit_user_url(current_user)
    else
      redirect_to redirect
    end    
  end

  def authsub_update
    if !params[:token].blank?
      begin
        authsubRequest = GData::Auth::AuthSub.new(params[:token])
        authsubRequest.private_key = private_key
        authsubRequest.upgrade
        
        current_user.update_attributes(:authsub_token => authsubRequest.token)
        current_user.log('Linked with Google Health')
        download_phr
        flash[:notice] = 'Your Google Health Profile was successfully linked'
        redirect_to :action => :show
      rescue Exception => e
        current_user.log("Error linking Google Health profile: #{e.exception}",nil,request.remote_ip,'Error linking with your Google Health profile.')
        flash[:error] = 'We could not link your Google Health profile. Please try again later.'
        redirect_to :action => :show
      end
    else
      flash[:error] = 'No token provided'
      redirect_to :action => :show
    end
  end

  def authsub
    # Guard against 'Link Profile' clicks from a stale PHR page
    if not current_user.authsub_token.nil? and current_user.authsub_token != '' then
      redirect_to :action => :show
      return
    end
    scope = GOOGLE_HEALTH_URL + '/feeds'
    if ROOT_URL == "localhost:3000"
      secure = false # when using localhost, secure has to be off (cf. http://code.google.com/apis/health/getting_started.html#RegisterGoogle)
    else
      secure = true  # set secure = true for signed AuthSub requests
    end
    next_url = authsub_phrccr_url

    sess = 1
    authsub_link = AuthSub.get_url(next_url, scope, secure, sess)
    redirect_to authsub_link
  end

  def download_phr
    server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"
    out = server.get_ccr(current_user.id, current_user.authsub_token, nil, ccr_profile_url)
    current_user.log("PHR download requested.",nil,request.remote_ip,"PHR download requested.")
  end

end
