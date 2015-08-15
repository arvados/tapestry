class OpenHumansController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::OPEN_HUMANS) }

  POST_HUIDS_URL = '/api/pgp/huids/'
  USER_DATA_URL = '/api/pgp/user-data/'

  def participate
    @open_humans_service = OauthService.where( :oauth2_service_type => OauthService::OPEN_HUMANS ).first
    # When OH links to this page, they send an origin parameter with value 'open-humans'.
    # We need to send that origin parameter back to them on the link request.
    # If there is no origin parameter, it means the user originated from Tapestry,
    # and we set it to 'external'.
    @origin = params[:origin]
    @origin ||= 'external'
  end

  def create_token
    oh_service = OauthService.open_humans.find(params[:service_id])
    redirect_to oh_service.oauth2_client.auth_code.authorize_url( :redirect_uri => oh_service.callback_url, :scope => oh_service.scope )
  end

  def disconnect
    success = false
    oh_service = OauthService.find_by_oauth2_service_type( OauthService::OPEN_HUMANS )
    oauth_token = current_user.oauth_tokens.find_by_oauth_service_id( oh_service.id )
    # Remove our HuID from Open Humans
    token = token_object( params[:token_id] )
    api_response = api_call token, :delete, POST_HUIDS_URL + current_user.hex + '/'
    success = api_response.status == 204
    if not success
      require 'pp'
      STDERR.puts "Error unlinking huID from Open Humans"
      STDERR.puts api_response.pretty_inspect()
      current_user.log("failure unlinking huID from Open Humans")
    else
      current_user.log("huID unlinked from Open Humans")
    end
    if oauth_token.revoke!
      success = true
      current_user.log("Account disconnected from Open Humans",nil,nil,"Account disconnected from Open Humans")
    end
    respond_to do |format|
      format.json do
        render :json => (success ? 'success' : 'error'), :status => (success ? 200 : 500)
      end
    end
  end

  def huids
    token = token_object( params[:token_id] )
    response = api_call token, :get, USER_DATA_URL

    respond_to do |format|
      format.json do
        render :json => { :token_id => params[:token_id],
                          :profile_id => response.parsed['id'],
                          :huids => response.parsed['huids'] }
      end
    end
  end

  def create_huid
    token = token_object( params[:token_id] )
    api_response = api_call token, :post, POST_HUIDS_URL, { 'value' => current_user.hex }
    success = api_response.status == 201
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
      api_response = api_call token, :post, POST_HUIDS_URL, { 'value' => current_user.hex }
      success = api_response.status == 201
      if not success
        require 'pp'
        STDERR.puts "Error sending huID to Open Humans"
        STDERR.puts api_response.pretty_inspect()
        current_user.log("failure sending huID to Open Humans")
      else
        current_user.log("huID sent to Open Humans")
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

  def token_record(oauth_token_id)
    current_user.oauth_tokens.joins(:oauth_service).where( :oauth_services => { :oauth2_service_type => OauthService::OPEN_HUMANS } ).find( oauth_token_id )
  end

  def token_object(oauth_token_id)
    token_record = token_record(oauth_token_id)
    client = token_record(params[:token_id]).oauth_service.oauth2_client
    token = OAuth2::AccessToken.from_hash( client, token_record.oauth2_token_hash )
    raise "Token expired" if token.expired?
    token
  end

  def api_call( token, verb, url, body_data = nil  )
    request = {
      :headers => {'Content-Type' => 'application/json'}
    }
    request[:body] = body_data.to_json if body_data
    begin
      response = token.send verb, url, request
    rescue OAuth2::Error => e
      response = e.response
    end
    response
  end

end
