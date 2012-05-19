class ProfileCell < Cell::Rails

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
