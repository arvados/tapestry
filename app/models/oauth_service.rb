class OauthService < ActiveRecord::Base
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'base64'
  require 'openssl'
  require 'sha1'
  include OpenSSL
  include PKey
  include ApplicationHelper

  has_many :oauth_tokens

  OPEN_HUMANS = :open_humans

  scope :open_humans, where( :oauth2_service_type => OPEN_HUMANS )

  ACCESS_TOKEN_URI = 'https://www.google.com/accounts/OAuthGetAccessToken'
  REVOKE_TOKEN_URI = 'https://www.google.com/accounts/AuthSubRevokeToken'

  def getrequesttoken_uri
    'https://www.google.com/accounts/OAuthGetRequestToken'
  end

  def authorizetoken_uri
    'https://www.google.com/accounts/OAuthAuthorizeToken'
  end

  def get_access_token(requesttoken, verifier)
    base_uri = ACCESS_TOKEN_URI
    uri = URI.parse(base_uri)
    formdata = {
      'oauth_consumer_key' => self.consumerkey,
      'oauth_token' => requesttoken,
      'oauth_verifier' => verifier,
      'oauth_nonce' => rand(2**64-1).to_s,
      'oauth_signature_method' => 'RSA-SHA1',
      'oauth_timestamp' => Time.new.to_i.to_s,
      'oauth_version' => '1.0'
    }
    formdata['oauth_signature'] = sign('POST', base_uri, formdata)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    req = Net::HTTP::Post.new(uri.scheme + '://' + uri.host + uri.request_uri)
    req.set_form_data(formdata)
    resp = http.request(req)
    return nil if resp.code == '400'
    raise "Error from #{base_uri}: #{resp.code} #{resp.message}" if resp.code != '200'
    @oauth_token = uridecode(resp.body.scan(/oauth_token=([^&]*)/)[0][0])
    @oauth_token_secret = uridecode(resp.body.scan(/oauth_token_secret=([^&]*)/)[0][0])
    return @oauth_token + ' ' + @oauth_token_secret
  end

  def revoke_token(token)
    resp = self.oauth_request(token, 'GET', URI.parse(REVOKE_TOKEN_URI), {})
    resp.code == '200'
    return resp
  end

  def oauth_request(token, http_method, uri, formdata)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    oauth = {
      'oauth_token' => token.accesstoken.split(' ')[0],
      'oauth_signature_method' => 'RSA-SHA1',
      'oauth_consumer_key' => self.consumerkey,
      'oauth_timestamp' => Time.now.to_i.to_s,
      'oauth_nonce' => rand(2**128-1).to_s(36),
      'oauth_version' => '1.0'
    }
    if http_method == 'POST'
      req = Net::HTTP::Post.new(uri.request_uri)
      req.set_form_data(formdata) if formdata.size > 0
    elsif http_method == 'GET'
      querystring = ''
      if !formdata.empty?
        querystring = (uri.request_uri.index('?') ? '&' : '?') + formdata.collect { |k,v| "#{uriencode(k)}=#{uriencode(v.to_s)}" }.join('&')
      end
      req = Net::HTTP::Get.new(uri.request_uri + querystring)
    else
      raise "#{http_method} method not supported"
    end
    oauth['oauth_signature'] = sign(http_method, uri.to_s, oauth.merge(formdata))
    req.add_field('Authorization', 'OAuth ' + oauth.collect { |k,v| "#{k}=\"#{uriencode(v)}\"" }.join(', '))
    return http.request(req)
  end

  def sign(method, uri, formdata)
    signdata = formdata.clone
    (base_uri, query_params) = uri.split('?')
    if !query_params.nil?
      query_params.split('&').each { |kv| (k,v)=kv.split('='); signdata[k]=v.to_s }
    end
    signme = [method,
              base_uri,
              (signdata.sort.map { |kv| uriencode(kv[0])+'='+uriencode(kv[1]) }).join('&')
             ].map{|x| uriencode(x)}.join('&')
    pkey = RSA.new(self[:privatekey])
    Base64.encode64(pkey.sign(OpenSSL::Digest::SHA1.new, signme))
  end

  def errors
    return []
  end
end
