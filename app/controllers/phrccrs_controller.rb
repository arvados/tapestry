class PhrccrsController < ApplicationController
  include PhrccrsHelper
  attr_accessor :ccr
  attr_accessor :outFile
  before_filter :store_location
  attr_accessor :processing_time
  attr_accessor :download_time

  def show
  end

  def review
    ccr_path = get_ccr_filename(current_user.id, false)
    if !File.exist?(ccr_path)
      feed = get_ccr(current_user)
    else
      feed = File.new(ccr_path)
    end
    @ccr = Nokogiri::XML(feed)
  end

  def create
    commit_action = params[:commit]
    if commit_action.eql?('Link Profile')
      authsub()
    elsif commit_action.eql?('Unlink Profile')
      authsub_revoke(current_user)
      flash[:notice] = 'Your profile has been successfully unlinked'
      redirect_to :action => :show
    elsif commit_action.eql?('Review PHR')
      redirect_to :controller => 'phrccrs', :action => 'review'
    elsif commit_action.eql?('Share my PHR with PGP')
      begin
        download_phr()
      rescue
        flash[:error] = 'There was an error saving your PHR.'
        redirect_to :action => :review
      else
        flash[:notice] = 'Your PHR has been shared with the PGP.'
        redirect_to '/'
      end
    elsif commit_action.eql?('Update PHR')
      begin
        download_phr()
      rescue
        flash[:error] = 'There was an error saving your PHR.'
      end
      redirect_to :action => :review
    else
      redirect_to :action => :show
    end
  end

  def unlink_googlehealth
    authsub_revoke(current_user)
    redirect_to edit_user_url(current_user)
  end

  def authsub_update
    if !params[:token].blank?
      begin
	authsubRequest = GData::Auth::AuthSub.new(params[:token])
        authsubRequest.private_key = private_key
	authsubRequest.upgrade
	
	current_user.update_attributes(:authsub_token => authsubRequest.token)
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
    outFile = File.new(get_ccr_filename(current_user.id), 'w')
    outFile.write(feed)
    outFile.close
  end
end
