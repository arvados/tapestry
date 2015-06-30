class OauthToken < ActiveRecord::Base
  require 'net/http'
  require 'net/https'
  require 'uri'
  include ApplicationHelper

  # If an existing access token has this many seconds left before it
  # expires, don't bother getting a new one.
  MIN_TTL_BEFORE_REFRESH = 120

  belongs_to :user
  belongs_to :oauth_service
  validates_uniqueness_of :user_id, :scope => :oauth_service_id

  serialize :oauth2_token_hash, Hash

  attr_protected :requesttoken
  attr_protected :accesstoken

  def authorized?
    accesstoken or oauth2_token_hash
  end

  def revoke!
    return nil if !authorized?
    self.destroy if self.oauth_service.revoke_token(self)
  end

  ### OAuth2 ###

  # Exchange a code (received from the oauth2callback sequence) for a
  # refresh token and an access token.
  def oauth2_callback code, callback_url
    token = oauth_service.oauth2_client.auth_code.
      get_token(code,
                :redirect_uri => callback_url,
                :scope => oauth_service.scope)
    self.oauth2_token_hash = token.to_hash
    save!
  end

  # Return the provider URL where the user should be redirected in
  # order to initiate the authorization process.
  def oauth2_authorize_url callback_url
    params = {
      :state => id,
      :redirect_uri => callback_url,
      :scope => oauth_service.scope,
      :response_type => 'code',
    }
    oauth_service.
      oauth2_client.
      auth_code.
      authorize_url params.merge(oauth_service.authorize_params)
  end

  def oauth2_expired?
    oauth2_token_hash and oauth2_token.expired?
  end

  # Deserialize an access token object (cf. 'oauth2' gem) from
  # oauth2_token_hash.
  def oauth2_token
    @oauth2_token ||= OAuth2::AccessToken.from_hash(oauth_service.oauth2_client,
                                                    oauth2_token_hash.dup)
  end

  # Serialize the access token object (cf. 'oauth2' gem) to
  # oauth2_token_hash before saving.
  def save *args
    oauth2_token_hash = @oauth2_token if @oauth2_token
    super
  end

  # Use this token to authorize an HTTP request. Get a new access
  # token first if the one on hand has expired (or will expires soon).
  def oauth2_request method, uri, params={}
    if not oauth2_token_hash
      migrate_from_oauth1!
    end
    if (oauth2_token.expires? and
        oauth2_token.expires_at < Time.now.to_i + MIN_TTL_BEFORE_REFRESH)
      oauth2_token.refresh!
      save
    end
    return oauth2_token.send method.to_s.downcase, uri, :params => params
  end

  ### OAuth1 ###

  # Get a request token (token+secret) from the OAuth1 provider. Store
  # the token+secret in the token record, and return an authorization
  # URL. (A user who visits this authorization URL and completes the
  # ensuring auth process will land on callback_uri with the new token
  # in params[:oauth_token] and a verifier in params[:oauth_verifier],
  # which should be passed to get_access_token() in order to trade the
  # request token for an access token.
  def authorize!(callback_uri)
    formdata = {
      'oauth_callback' => callback_uri,
      'oauth_consumer_key' => self.oauth_service.consumerkey,
      'oauth_nonce' => rand(2**64-1).to_s,
      'oauth_signature_method' => 'RSA-SHA1',
      'oauth_timestamp' => Time.new.to_i.to_s,
      'scope' => self.oauth_service.scope,
      'oauth_version' => '1.0'
    }
    base_uri = self.oauth_service.getrequesttoken_uri
    uri = URI.parse(base_uri)
    formdata['oauth_signature'] = oauth_service.sign('POST', base_uri, formdata)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(formdata)
    resp = http.request(req)
    oauth_token_scan = resp.body.scan(/oauth_token=([^&]*)/)
    if resp.nil? then
      return nil,''
    elsif oauth_token_scan.empty? then
      return nil,resp.body
    end
    @oauth_token = uridecode(oauth_token_scan[0][0])
    @oauth_token_secret = uridecode(resp.body.scan(/oauth_token_secret=([^&]*)/)[0][0])
    self.requesttoken = @oauth_token + ' ' + @oauth_token_secret
    save!
    return true,@oauth_service.authorizetoken_uri + '?oauth_token=' + uriencode(@oauth_token)
  end

  def get_access_token(token, verifier)
    return true if authorized?
    self.accesstoken = self.oauth_service.get_access_token(token, verifier)
    save!
    self.accesstoken
  end

  def oauth_request(method, uri, formdata)
    return self.oauth_service.oauth_request(self, method, uri, formdata)
  end

protected

  def migrate_from_oauth1!
    raise "Migration from OAuth1 is not implemented. Re-authorize using OAuth2."
  end
end
