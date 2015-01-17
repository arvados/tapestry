class ThirdPartyController < ApplicationController

  def index
    @studies = Study.approved.third_party.open_now

    if include_section?( Section::OPEN_HUMANS ) && OauthService.where( :oauth2_service_type => OauthService::OPEN_HUMANS ).exists?
      @open_humans_services = OauthService.where( :oauth2_service_type => OauthService::OPEN_HUMANS )
      @open_humans_tokens = current_user.oauth_tokens.joins(:oauth_service).where( 'oauth2_token_hash is not null' ).where( :oauth_services => { :oauth2_service_type => OauthService::OPEN_HUMANS } )
    end
  end

end
