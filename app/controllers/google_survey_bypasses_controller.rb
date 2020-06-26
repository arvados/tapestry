
class GoogleSurveyBypassesController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::GOOGLE_SURVEYS) }
  before_filter :store_location
  skip_before_filter :login_required, :only => [ :record ]
  skip_before_filter :ensure_enrolled, :only => [ :record ]

  def record
    if not params[:token]
      render template => 'google_survey_bypasses/error'
      return
    end

    if current_user
      @gsb = GoogleSurveyBypass.where(:token => params[:token], :used => nil, :user_id => current_user.id).first
    else
      @gsb = GoogleSurveyBypass.where(:token => params[:token], :used => nil).first
    end
    if @gsb.nil?
      render :template => 'google_survey_bypasses/error'
      return
    end
    current_user = @gsb.user

    @gsb.used = Time.now().utc
    @gsb.save!

    render
  end

end
