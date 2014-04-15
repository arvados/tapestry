class FamilyRelationCell < TapestryBaseCell

  def dashboard_summary(options)
    @user = options[:user]
    render
  end

end
