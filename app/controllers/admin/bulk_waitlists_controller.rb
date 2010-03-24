class Admin::BulkWaitlistsController < Admin::AdminControllerBase
  def new
    @phase = params[:phase]
  end

  def create
    @phase = params[:phase]
    erroneous_emails = []
    successful_bulk_waitlists = 0
    params[:emails].each do |email|
      if user = User.find_by_email(email.strip)
        Waitlist.create!(:user => user, :reason => params[:reason], :phase => @phase)
        successful_bulk_waitlists += 1
      else
        erroneous_emails << CGI.escapeHTML(email)
      end
    end

    if erroneous_emails.any?
      flash[:warning] = "The following emails do not correspond to users in the system:<br/>#{erroneous_emails.join("<br/>")}"
    end

    flash[:notice] = "#{successful_bulk_waitlists} user(s) bulk waitlisted in phase #{CGI.escapeHTML(@phase)}."

    redirect_to new_admin_bulk_waitlist_url(:phase => @phase)
  end
end
