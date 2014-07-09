class Admin::RemovalRequestsController < Admin::AdminControllerBase

  # GET /admin/removal_requests
  # GET /admin/removal_requests.xml
  def index
    @admin_removal_requests = RemovalRequest.
      all(:order => 'id desc').
      paginate(:page => params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_removal_requests }
    end
  end

  # GET /admin/removal_requests/1
  # GET /admin/removal_requests/1.xml
  def show
    @admin_removal_request = RemovalRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_removal_request }
    end
  end

  # PUT /admin/removal_requests/1
  # PUT /admin/removal_requests/1.xml
  def update
    @removal_request = RemovalRequest.find(params[:id])

    @removal_request.update_attributes(params[:removal_request])
    if params[:close].present?
      @removal_request.update_attributes(:fulfilled_at => Time.now,
                                         :fulfilled_by => current_user)
    end
    redirect_to admin_removal_requests_path
  end

end
