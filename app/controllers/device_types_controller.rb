class DeviceTypesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

  # GET /device_types
  # GET /device_types.xml
  def index
    @device_types = DeviceType.all.sort { |a,b| a.name <=> b.name }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @device_types }
    end
  end

  # GET /device_types/new
  # GET /device_types/new.xml
  def new
    @device_type = DeviceType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @device_type }
    end
  end

  # GET /device_types/1/edit
  def edit
    @device_type = DeviceType.find(params[:id])
  end

  # POST /device_types
  # POST /device_types.xml
  def create
    @device_type = DeviceType.new(params[:device_type])

    respond_to do |format|
      if @device_type.save
        flash[:notice] = 'Device type was successfully created.'
        format.html { redirect_to(device_types_url) }
        format.xml  { render :xml => @device_type, :status => :created, :location => @device_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @device_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /device_types/1
  # PUT /device_types/1.xml
  def update
    @device_type = DeviceType.find(params[:id])

    respond_to do |format|
      if @device_type.update_attributes(params[:device_type])
        flash[:notice] = 'Device type was successfully updated.'
        format.html { redirect_to(device_types_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /device_types/1
  # DELETE /device_types/1.xml
  def destroy
    @device_type = DeviceType.find(params[:id])
    @device_type.destroy

    respond_to do |format|
      format.html { redirect_to(device_types_url) }
      format.xml  { head :ok }
    end
  end
end
