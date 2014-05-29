class StudyCell < TapestryBaseCell

  def dashboard_summary(options)
    @user = options[:user]
    @studies_pending = Study.open_now.select do |s|
      sp = s.study_participants.where('user_id = ?', @user.id).first if @user
      sp.nil? or sp.is_undecided?
    end

    @third_party_studies_pending = @studies_pending.select &:is_third_party
    @studies_pending.reject! &:is_third_party

    render
  end

end
