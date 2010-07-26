class PhrccrsController < ApplicationController
  include PhrccrsHelper
  attr_accessor :ccr
  attr_accessor :outFile
  before_filter :store_location
  attr_accessor :processing_time
  attr_accessor :download_time

  def show
    if !current_user.authsub_token.blank?
      redirect_to :action => 'review'
    end
  end

  def review
    ccr_list = Dir.glob(get_ccr_path(current_user.id) + '*').reverse
    if ccr_list.length == 0
      flash[:error] = 'You do not have any PHRs saved. Click the "Refresh PHR" button to get the latest version.'
      return
    end
    
    @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }

    version = params[:version]
    if version && !version.empty?
      for i in 0.. ccr_list.length - 1 do
      	  if @ccr_history[i] == version
	     feed = File.new(ccr_list[i])
	     @current_version = version
	     break
	  end
      end
    else
      feed = File.new(ccr_list[0])
      @current_version = @ccr_history[0]
    end

    @ccr = Nokogiri::XML(feed)
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
      rescue
        flash[:error] = 'There was an error saving your PHR.'
      end
      redirect_to :action => :review
    elsif params[:deleteccr]
      timestamp_regex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{0,3})?Z$/
      timestamp = params[:deleteccr]
      if timestamp.scan(timestamp_regex).length > 0
        ccr_filename = get_ccr_filename(current_user.id, false, timestamp)
        File.delete(ccr_filename)
	current_user.log("Deleted PHR (#{ccr_filename})")
      end
      redirect_to :action => :review
    else
      redirect_to :action => :show
    end
  end

  def unlink_googlehealth(redirect = nil)
    authsub_revoke(current_user)
    current_user.log('Unlinked from Google Health')
    flash[:notice] = 'Unlinked from Google Health'
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
      rescue GData::Client::Error => ex
	flash[:error] = 'We could not link your Google Health profile. Please try again.'
	redirect_to :action => :show
      end
    else
      flash[:error] = 'No token provided'
      redirect_to :action => :show
    end
  end

  def authsub
    if ROOT_URL == "enroll-si.personalgenomes.org"
      scope = 'https://www.google.com/h9/feeds'
      next_url = 'http://enroll-si.personalgenomes.org/phrccr/authsub'
    elsif ROOT_URL == "enroll-dev.personalgenomes.org"
      scope = 'https://www.google.com/h9/feeds'
      next_url = 'http://enroll-dev.personalgenomes.org/phrccr/authsub'
    else
      scope = 'https://www.google.com/health/feeds'
      next_url = 'https://enroll.personalgenomes.org/phrccr/authsub'
    end

    secure = true  # set secure = true for signed AuthSub requests
    sess = 1
    authsub_link = AuthSub.get_url(next_url, scope, secure, sess)
    redirect_to authsub_link    
  end

  def download_phr
    feed = get_ccr(current_user)
    ccr = Nokogiri::XML(feed)
    updated = ccr.xpath('/xmlns:feed/xmlns:updated').inner_text
    ccr_filename = get_ccr_filename(current_user.id, true, updated)
    if !File.exist?(ccr_filename)
      outFile = File.new(ccr_filename, 'w')
      outFile.write(feed)
      outFile.close
      current_user.log("Downloaded PHR (#{ccr_filename})")
    end
  end
end
