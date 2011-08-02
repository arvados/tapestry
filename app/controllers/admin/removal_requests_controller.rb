class Admin::RemovalRequestsController < ApplicationController
  # GET /admin/removal_requests
  # GET /admin/removal_requests.xml
  def index
    @admin_removal_requests = RemovalRequest.all

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

  # GET /admin/removal_requests/new
  # GET /admin/removal_requests/new.xml
  def new
    @admin_removal_request = RemovalRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_removal_request }
    end
  end

  # GET /admin/removal_requests/1/edit
  def edit
    @admin_removal_request = RemovalRequest.find(params[:id])
  end

  # POST /admin/removal_requests
  # POST /admin/removal_requests.xml
  def create
    @admin_removal_request = RemovalRequest.new(params[:admin_removal_request])

    respond_to do |format|
      if @admin_removal_request.save
        format.html { redirect_to(@admin_removal_request, :notice => 'Removal request was successfully created.') }
        format.xml  { render :xml => @admin_removal_request, :status => :created, :location => @admin_removal_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_removal_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/removal_requests/1
  # PUT /admin/removal_requests/1.xml
  def update
    @admin_removal_request = RemovalRequest.find(params[:id])

    respond_to do |format|
      if @admin_removal_request.update_attributes(params[:admin_removal_request])
        format.html { redirect_to(@admin_removal_request, :notice => 'Removal request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_removal_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/removal_requests/1
  # DELETE /admin/removal_requests/1.xml
  def destroy
    @admin_removal_request = RemovalRequest.find(params[:id])
    @admin_removal_request.destroy

    respond_to do |format|
      format.html { redirect_to(admin_removal_requests_url) }
      format.xml  { head :ok }
    end
  end
end
