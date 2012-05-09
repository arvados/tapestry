class SurveyCell < Cell::Rails

  include ApplicationHelper
  helper_method :are_n_things

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
