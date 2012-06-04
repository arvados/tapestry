class StudyCell < Cell::Rails

  include ApplicationHelper
  helper_method :are_n_things

  def dashboard_summary(options)
    @user = options[:user]
    @studies_pending = Study.approved.select(&:is_open?).select do |s|
      sp = s.study_participants.where('user_id = ?', @user.id).first if @user
      sp.nil? or sp.is_undecided?
    end
    render
  end

end
