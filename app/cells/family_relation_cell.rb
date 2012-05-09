class FamilyRelationCell < Cell::Rails

  include ApplicationHelper
  helper_method :n_things

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
