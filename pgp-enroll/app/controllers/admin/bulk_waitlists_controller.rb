class Admin::BulkWaitlistsController < Admin::AdminControllerBase
  def new
  end

  def create
    erroneous_emails = []
    successful_bulk_waitlists = 0
    params[:emails].each do |email|
      if user = User.find_by_email(email)
        Waitlist.create(:user => user, :reason => params[:reason])
        successful_bulk_waitlists += 1
      else
        erroneous_emails << email
      end
    end

    if erroneous_emails.any?
      flash[:warning] = "The following emails do not correspond to users in the system:<br/>#{erroneous_emails.join("<br/>")}"
    end

    flash[:notice] = "#{successful_bulk_waitlists} user(s) bulk waitlisted."

    redirect_to new_admin_bulk_waitlist_url
  end
end
