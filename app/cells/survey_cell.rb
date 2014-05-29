class SurveyCell < TapestryBaseCell

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
