class Admin::UserMailerPreviewsController < Admin::AdminControllerBase

  def unclaimed_kit_reminder
    if params[:a] and params[:b]
      @sp = StudyParticipant.where('user_id=? and study_id=?',params[:a],params[:b]).first
    end
    @sp ||= StudyParticipant.where('user_id=?', current_user.id).first
    @sp ||= StudyParticipant.where('kit_last_sent_at is not ?', nil).last
    @sp ||= StudyParticipant.last
    @sp ||= StudyParticipant.new(:user => current_user, :study => Study.new)
    render :text => UserMailer.unclaimed_kit_reminder(@sp).to_s, :content_type => 'text/plain'
  end
end
