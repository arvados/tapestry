class Admin::BulkPromotionsController < Admin::AdminControllerBase
  def new
    @require = nil
    if params[:require]
      @require = EnrollmentStep.find_by_keyword(params[:require])
    end
  end

  def create
    @require = nil
    if params[:require]
      @require = EnrollmentStep.find_by_keyword(params[:require])
    end
    erroneous_emails = []
    requirement_missing_emails = []
    successful_bulk_promotions = 0
    params[:emails].each do |email|
      if user = User.find_by_email(email.strip)
        if @require
          if user.last_completed_enrollment_step == @require
            user.promote!
            successful_bulk_promotions += 1
          else
            requirement_missing_emails << CGI.escapeHTML(email)
          end
        else
          user.promote!
          successful_bulk_promotions += 1
        end
      else
        erroneous_emails << CGI.escapeHTML(email)
      end
    end

    warnings = []
    if erroneous_emails.any?
      warnings << "The following emails do not correspond to users in the system:<br/>#{erroneous_emails.join("<br/>")}"
    end

    if requirement_missing_emails.any?
      warnings << "The following emails do not have #{@require.title} as their last step:<br/>#{requirement_missing_emails.join("<br/>")}"
    end

    if warnings.any?
      flash[:warning] = warnings.join("<br/>")
    end

    flash[:notice] = "#{successful_bulk_promotions} user(s) bulk promoted."

    redirect_to new_admin_bulk_promotion_url(:require => params[:require])
  end
end
