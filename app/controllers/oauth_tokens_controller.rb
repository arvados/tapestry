class OauthTokensController < ApplicationController
  include ApplicationHelper
  skip_before_filter :ensure_enrolled

  def index
    @services = OauthService.all
    @mytokens = current_user.oauth_tokens
    @authorized = {}
    @services.each { |s|
      t = @mytokens.where(:oauth_service_id => s.id)
      @authorized[s.id] = (!t.empty? and t[0].authorized?)
    }
  end

  # Obtain OAuth1 or OAuth2 authorization to use a service on behalf
  # of the current user.
  def authorize
    token = current_user.oauth_tokens.find_or_create_by_oauth_service_id(params[:id])
    if token.authorized? then
      flash[:notice] = 'You have already authorized this service.'
      redirect_to oauth_tokens_path
      return
    elsif token.oauth_service.oauth2_service_type
      # OAuth2
      return redirect_to token.oauth2_authorize_url(oauth2callback_url)
    else
      # OAuth1
      callback_uri = get_oauth_access_token_url + '?next_page=' + uriencode(oauth_tokens_path)
      (status,destination) = token.authorize! callback_uri
      if not status.nil?
        redirect_to destination
      else
        flash[:error] = "Unable to authorize: #{destination}. Please try again later."
        redirect_to request.env['HTTP_REFERER']
      end
    end
  end

  def oauth2callback
    nextpage = params[:next_page] || oauth_tokens_path
    token = OauthToken.where(:id => params[:state].to_i,
                             :user_id => current_user.id).first
    if token and token.oauth2_callback params[:code], oauth2callback_url
      flash[:notice] = "Authorization for #{token.oauth_service.name} was successful."
    else
      flash[:error] = "Authorization for #{token.oauth_service.name} failed (or perhaps you cancelled it)."
    end

    if params[:next_page]
      redirect_to params[:next_page]
    else
      redirect_to oauth_tokens_path
    end
  end

  def revoke
    servicename = OauthService.find(params[:id]).name
    token = OauthToken.find_by_user_id_and_oauth_service_id(current_user.id, params[:id])
    if token.nil?
      flash[:error] = "Could not find a token for #{servicename}."
    elsif token.revoke!
      flash[:notice] = "Authorization to use the #{servicename} service has been revoked."
    else
      flash[:error] = "Could not revoke authorization to use #{servicename} -- perhaps it is not even authorized?"
    end
    redirect_to oauth_tokens_path
  end

  def get_access_token
    mytokens = OauthToken.where(:user_id => current_user.id)
    if params[:oauth_token].nil?
      flash[:error] = "The OAuth server did not provide a token."
    elsif (token = mytokens.select { |x| x.requesttoken.to_s.split(' ')[0]==params[:oauth_token] }[0]).nil?
      flash[:error] = "The OAuth server provided a token I don't recognize: \"#{params[:oauth_token]}\""
    elsif token.get_access_token(params[:oauth_token], params[:oauth_verifier])
      flash[:notice] = "Authorization for #{token.oauth_service.name} was successful."
    else
      flash[:error] = "Authorization for #{token.oauth_service.name} failed (or perhaps you cancelled it)."
    end

    if params[:next_page]
      redirect_to params[:next_page]
    else
      redirect_to oauth_tokens_path
    end
  end
end
