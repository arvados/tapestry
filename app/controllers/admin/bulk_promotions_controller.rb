class Admin::BulkPromotionsController < Admin::AdminControllerBase
  def new
  end

  def create
    erroneous_emails = []
    successful_bulk_promotions = 0
    params[:emails].each do |email|
      if user = User.find_by_email(email.strip)
        user.promote!
        successful_bulk_promotions += 1
      else
        erroneous_emails << email
      end
    end

    if erroneous_emails.any?
      flash[:warning] = "The following emails do not correspond to users in the system:<br/>#{erroneous_emails.join("<br/>")}"
    end

    flash[:notice] = "#{successful_bulk_promotions} user(s) bulk promoted."

    redirect_to new_admin_bulk_promotion_url
  end
end
