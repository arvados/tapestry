class ThirdPartyController < ApplicationController

  def index
    @studies = Study.approved.third_party.open_now
  end

end
