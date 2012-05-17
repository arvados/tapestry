class UserCell < Cell::Rails

  include ApplicationHelper
  helper_method :humanize_date
  helper_method :n_things

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
