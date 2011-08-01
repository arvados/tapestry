class UnusedKitNamesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

  # GET /unused_kit_names
  # GET /unused_kit_names.xml
  def index
    @unused_kit_names = UnusedKitName.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @unused_kit_names }
    end
  end

  # GET /unused_kit_names/1
  # GET /unused_kit_names/1.xml
  def show
    @unused_kit_name = UnusedKitName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unused_kit_name }
    end
  end

  # GET /unused_kit_names/new
  # GET /unused_kit_names/new.xml
  def new
    @unused_kit_name = UnusedKitName.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @unused_kit_name }
    end
  end

  # GET /unused_kit_names/1/edit
  def edit
    @unused_kit_name = UnusedKitName.find(params[:id])
  end

  # POST /unused_kit_names
  # POST /unused_kit_names.xml
  def create
    @unused_kit_name = UnusedKitName.new(params[:unused_kit_name])

    respond_to do |format|
      if @unused_kit_name.save
        format.html { redirect_to(@unused_kit_name, :notice => 'Unused kit name was successfully created.') }
        format.xml  { render :xml => @unused_kit_name, :status => :created, :location => @unused_kit_name }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @unused_kit_name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /unused_kit_names/1
  # PUT /unused_kit_names/1.xml
  def update
    @unused_kit_name = UnusedKitName.find(params[:id])

    respond_to do |format|
      if @unused_kit_name.update_attributes(params[:unused_kit_name])
        format.html { redirect_to(@unused_kit_name, :notice => 'Unused kit name was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unused_kit_name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /unused_kit_names/1
  # DELETE /unused_kit_names/1.xml
  def destroy
    @unused_kit_name = UnusedKitName.find(params[:id])
    @unused_kit_name.destroy

    respond_to do |format|
      format.html { redirect_to(unused_kit_names_url) }
      format.xml  { head :ok }
    end
  end
end
