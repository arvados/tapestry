class ThirdPartyController < ApplicationController

  def index
    @studies = Study.approved.third_party.open_now

    if include_section?( Section::OPEN_HUMANS )
      @open_humans_service = OauthService.where( :oauth2_service_type => OauthService::OPEN_HUMANS ).first
    end
  end

end
