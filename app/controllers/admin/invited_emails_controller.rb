class Admin::InvitedEmailsController < Admin::AdminControllerBase
  def index
    @invited_emails = InvitedEmail.all
    @number_of_accepted_emails = InvitedEmail.accepted.count
  end

  def new
  end

  def create
    @emails = params[:emails].split

    if @emails
      @emails.each do |email|
        InvitedEmail.create(:email => email)
      end
    end

    redirect_to admin_invited_emails_path
  end
end
