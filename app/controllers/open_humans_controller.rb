class OpenHumansController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::OPEN_HUMANS) }

  POST_HUIDS_URL = '/api/pgp/huids/'
  USER_DATA_URL = '/api/pgp/user-data/'
  TOKEN_REVOCATION_URL = '/oauth2/revoke_token/'

  def participate
    @open_humans_service = OauthService.where( :oauth2_service_type => OauthService::OPEN_HUMANS ).first
    # When OH links to this page, they send an origin parameter with value 'open-humans'.
    # We need to send that origin parameter back to them on the link request.
    # If there is no origin parameter, it means the user originated from Tapestry,
    # and we set it to 'external'.
    @origin = params[:origin]
    @origin ||= 'external'
    @user_token = @open_humans_service.oauth_tokens.find_by_user_id( current_user.id )
    if @user_token
      # We call huids_worker here to test the connection. If it has been severed on the OH end,
      # this will clean up on our end as well and make sure that we present the reconnect option
      # to the user
      huids_worker(@user_token.id)
      # The token could have been cleared in disconnect_worker because it was invalid
      @user_token = @open_humans_service.oauth_tokens.find_by_user_id( current_user.id )
    end
  end

  def create_token
    oh_service = OauthService.open_humans.find(params[:service_id])
    redirect_to oh_service.oauth2_client.auth_code.authorize_url( :redirect_uri => oh_service.callback_url, :scope => oh_service.scope )
  end

  def disconnect
    success = disconnect_worker
    respond_to do |format|
      format.json do
        render :json => (success ? 'success' : 'error'), :status => (success ? 200 : 500)
      end
    end
  end

  def huids
    api_response = huids_worker
    respond_to do |format|
      format.json do
        render :json => { :token_id => params[:token_id],
                          :profile_id => api_response.parsed['id'],
                          :huids => api_response.parsed['huids'] }
      end
    end
  end

  def create_huid
    token = token_object( params[:token_id] )
    api_response = api_call token, :post, POST_HUIDS_URL, { 'value' => current_user.hex }.to_json
    success = api_response.status == 201
    if not success
      require 'pp'
      STDERR.puts "Error sending huID to Open Humans"
      STDERR.puts api_response.pretty_inspect()
      current_user.log("Failed to send huID to Open Humans")
    else
      current_user.log("Sent huID to Open Humans")
    end

    respond_to do |format|
      format.json do
        render :json => (success ? 'success' : 'error'), :status => (success ? 200 : 500)
      end
    end
  end

  def callback
    oh_service = OauthService.find_by_oauth2_service_type( OauthService::OPEN_HUMANS )
    @origin = params[:origin]
    @origin ||= 'external'
    token = oh_service.oauth2_client.auth_code.
      get_token(params[:code],
                :redirect_uri => oh_service.callback_url,
                :scope => oh_service.scope)
    if token
      oauth_token = current_user.oauth_tokens.find_or_create_by_oauth_service_id( oh_service.id )
      oauth_token.oauth2_token_hash = token.to_hash
      oauth_token.save!
      current_user.log("Account linked with Open Humans",nil,nil,"Account linked with Open Humans")
      # Now send the huID immediately.
      api_response = api_call token, :post, POST_HUIDS_URL, { 'value' => current_user.hex }.to_json
      success = api_response.status == 201
      if not success
        require 'pp'
        STDERR.puts "Error sending huID to Open Humans"
        STDERR.puts api_response.pretty_inspect()
        current_user.log("Failed to send huID to Open Humans")
      else
        current_user.log("Sent huID to Open Humans")
      end
    end
    if @origin == 'open-humans'
      uri = URI(oh_service.endpoint)
      redirect_to "https://#{uri.host}/member/me/research-data/"
    else
      redirect_to open_humans_participate_path
    end
  end

private

  def huids_worker(token_id = nil)
    token_id = params[:token_id] if token_id.nil?

    token = token_object( token_id )
    api_response = api_call token, :get, USER_DATA_URL
    success = api_response.status == 200
    if not success
      require 'pp'
      STDERR.puts "Error getting huID from Open Humans"
      STDERR.puts api_response.pretty_inspect()
      current_user.log("Error getting huID from Open Humans - maybe the link was disconnected from their end.")
      disconnect_worker(token_id)
    end
    api_response
  end

  def disconnect_worker(token_id = nil)
    token_id = params[:token_id] if token_id.nil?
    success = false
    oh_service = OauthService.find_by_oauth2_service_type( OauthService::OPEN_HUMANS )
    oauth_token = current_user.oauth_tokens.find_by_oauth_service_id( oh_service.id )
    token = token_object( token_id )
    # Remove our HuID from Open Humans
    api_response = api_call token, :delete, POST_HUIDS_URL + current_user.hex + '/'
    success = api_response.status == 204
    if not success
      require 'pp'
      STDERR.puts "Error unlinking huID from Open Humans"
      STDERR.puts api_response.pretty_inspect()
      current_user.log("Failed to unlink huID from Open Humans")
    else
      current_user.log("Unlinked huID from Open Humans")
    end
    # Invalidate access and refresh tokens on the Open Humans side
    require 'cgi'
    api_response = api_call token, :post, TOKEN_REVOCATION_URL, "token=#{CGI::escape(token.token)}&client_id=#{CGI::escape(token.client.id)}&client_secret=#{CGI::escape(token.client.secret)}", 'application/x-www-form-urlencoded'
    success = api_response.status == 200
    if not success
      require 'pp'
      STDERR.puts "Error invalidating access and refresh tokens at Open Humans"
      STDERR.puts api_response.pretty_inspect()
      current_user.log("Failed to invalidate access and refresh tokens at Open Humans")
    else
      current_user.log("Invalidated access and refresh tokens at Open Humans")
    end

    if oauth_token.destroy
      success = true
      current_user.log("Account disconnected from Open Humans",nil,nil,"Account disconnected from Open Humans")
    else
      success = false
    end
    # We deliberately return success based on the outcome of the local token revocation, only.
    # That's the only thing we can control anyway, and also what drives all logic on our end.
    success
  end

  def token_record(oauth_token_id)
    current_user.oauth_tokens.joins(:oauth_service).where( :oauth_services => { :oauth2_service_type => OauthService::OPEN_HUMANS } ).find( oauth_token_id )
  end

  def token_object(oauth_token_id)
    token_record = token_record(oauth_token_id)
    client = token_record(oauth_token_id).oauth_service.oauth2_client
    token = OAuth2::AccessToken.from_hash( client, token_record.oauth2_token_hash )
    raise "Token expired" if token.expired?
    token
  end

  def api_call( token, verb, url, body_data = nil, content_type = 'application/json' )
    request = {
      :headers => {'Content-Type' => content_type }
    }
    request[:body] = body_data if body_data
    begin
      response = token.send verb, url, request
    rescue OAuth2::Error => e
      response = e.response
    end
    response
  end

end
