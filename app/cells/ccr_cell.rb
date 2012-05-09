class CcrCell < Cell::Rails

  include ApplicationHelper
  helper_method :humanize_date

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
