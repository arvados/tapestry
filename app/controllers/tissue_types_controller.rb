class TissueTypesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_admin

  # GET /tissue_types
  # GET /tissue_types.xml
  def index
    @tissue_types = TissueType.all.sort { |a,b| a.name <=> b.name }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tissue_types }
    end
  end

  # GET /tissue_types/new
  # GET /tissue_types/new.xml
  def new
    @tissue_type = TissueType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tissue_type }
    end
  end

  # GET /tissue_types/1/edit
  def edit
    @tissue_type = TissueType.find(params[:id])
  end

  # POST /tissue_types
  # POST /tissue_types.xml
  def create
    @tissue_type = TissueType.new(params[:tissue_type])

    respond_to do |format|
      if @tissue_type.save
        flash[:notice] = 'Tissue type was successfully created.'
        format.html { redirect_to(tissue_types_url) }
        format.xml  { render :xml => @tissue_type, :status => :created, :location => @tissue_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tissue_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tissue_types/1
  # PUT /tissue_types/1.xml
  def update
    @tissue_type = TissueType.find(params[:id])

    respond_to do |format|
      if @tissue_type.update_attributes(params[:tissue_type])
        flash[:notice] = 'Tissue type was successfully updated.'
        format.html { redirect_to(tissue_types_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tissue_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tissue_types/1
  # DELETE /tissue_types/1.xml
  def destroy
    @tissue_type = TissueType.find(params[:id])
    @tissue_type.destroy

    respond_to do |format|
      format.html { redirect_to(tissue_types_url) }
      format.xml  { head :ok }
    end
  end
end
