class OpenHumansController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::OPEN_HUMANS) }

  CALLBACK_URL = 'http://localhost:8000/auth/open-humans/callback'
  SCOPE = 'read write pgp'
  ENDPOINT_URL = "http://open-humans-staging.herokuapp.com"
  AUTHORIZE_URL = '/oauth2/authorize/'
  TOKEN_URL = '/oauth2/token/'
  POST_HUIDS_URL = '/api/pgp/huids/'
  USER_DATA_URL = '/api/pgp/user-data/'

  def create_token
    # params[:oauth2_service_type] could be used generically
    oh_service = OauthService.find_by_oauth2_service_type( OauthService::OPEN_HUMANS )
    redirect_to client(oh_service).auth_code.authorize_url( :redirect_uri => CALLBACK_URL, :scope => SCOPE )
  end

  def huids
    token = token_object( params[:token_id] )
    response = api_call token, :get, USER_DATA_URL

    respond_to do |f|
      f.json { render :json => response.parsed['huids'] }
    end
  end

  def create_huid
    token = token_object( params[:token_id] )
    api_call token, :post, POST_HUIDS_URL, { 'value' => current_user.hex }

    redirect_to third_party_index_path
  end

  def callback
    oh_service = OauthService.find_by_oauth2_service_type( OauthService::OPEN_HUMANS )
    token = client(oh_service).auth_code.get_token( params['code'], :redirect_uri => CALLBACK_URL, :scope => SCOPE )
    if token
      current_user.oauth_tokens.create( {
        :oauth_service => oh_service,
        :oauth2_token_hash => token.to_hash
      })
    end
    redirect_to third_party_index_path
  end

private

  def client(service)
    OAuth2::Client.new(
      service.oauth2_key,
      service.oauth2_secret,
      :authorize_url => AUTHORIZE_URL,
      :token_url => TOKEN_URL,
      :site => ENDPOINT_URL
    )
  end

  def token_record(oauth_token_id)
    current_user.oauth_tokens.joins(:oauth_service).where( :oauth_services => { :oauth2_service_type => OauthService::OPEN_HUMANS } ).find( oauth_token_id )
  end

  def token_object(oauth_token_id)
    token_record = token_record(oauth_token_id)
    client = client( token_record(params[:token_id]).oauth_service )
    token = OAuth2::AccessToken.from_hash( client, token_record.oauth2_token_hash )
    if token.expired?
      if token.refresh_token.nil?
        raise "Needs redirect"
      else
        token.refresh!
      end
    end
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
    if response.parsed && response.parsed['value']
      response_msg = response.parsed['value']
      if response_msg =~ /must be unique/
        puts "OH RESPONSE: Already posted this huID"
      else
        puts "OH RESPONSE: Got some kind of message: #{response_msg}"
      end
    end
    puts "OH RESPONSE: Not successful" unless response.status == 201
    response
  end

end
