class Admin::UserMailerPreviewsController < Admin::AdminControllerBase

  def email_change_notification
    @u = User.new(:email => 'new_email@example.com', :first_name => 'Axel', :last_name => 'Foley')
    render_plain UserMailer.email_change_notification(@u, 'old_email@example.com')
  end

  def unclaimed_kit_reminder
    if params[:a] and params[:b]
      @sp = StudyParticipant.where('user_id=? and study_id=?',params[:a],params[:b]).first
    end
    @sp ||= StudyParticipant.where('user_id=?', current_user.id).first
    @sp ||= StudyParticipant.where('kit_last_sent_at is not ?', nil).last
    @sp ||= StudyParticipant.last
    @sp ||= StudyParticipant.new(:user => current_user, :study => Study.new)
    render_plain UserMailer.unclaimed_kit_reminder(@sp)
  end

  def dataset_notification
    @u = User.where('hex=?', params[:a]).first || current_user
    @d = Dataset.where('id=?', params[:b]).first || Dataset.last
    render_plain UserMailer.dataset_notification_message specimen_analysis_data_index_url, @u, @d
  end

  protected
  def render_plain(t)
    t = t.to_s
    if t.match /: quoted-printable/
      t.gsub!(/=\r\n/, "")
      t.gsub!(/=([\dA-F]{2})/) { $1.hex.chr }
    end
    render(:text => t,
           :content_type => 'text/plain')
  end
end
