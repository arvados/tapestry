class SampleTypesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

  # GET /sample_types
  # GET /sample_types.xml
  def index
    @sample_types = SampleType.all.sort { |a,b| a.name <=> b.name }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sample_types }
    end
  end

  # GET /sample_type/1
  # GET /sample_type/1.xml
  def show
    @sample_type = SampleType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sample_type }
    end
  end


  # GET /sample_types/new
  # GET /sample_types/new.xml
  def new
    @sample_type = SampleType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample_type }
    end
  end

  # GET /sample_types/1/edit
  def edit
    @sample_type = SampleType.find(params[:id])
  end

  # POST /sample_types
  # POST /sample_types.xml
  def create
    @sample_type = SampleType.new(params[:sample_type])

    respond_to do |format|
      if @sample_type.save
        flash[:notice] = 'Sample type was successfully created.'
        format.html { redirect_to(sample_types_url) }
        format.xml  { render :xml => @sample_type, :status => :created, :location => @sample_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sample_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sample_types/1
  # PUT /sample_types/1.xml
  def update
    @sample_type = SampleType.find(params[:id])

    respond_to do |format|
      if @sample_type.update_attributes(params[:sample_type])
        flash[:notice] = 'Sample type was successfully updated.'
        format.html { redirect_to(sample_types_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sample_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sample_types/1
  # DELETE /sample_types/1.xml
  def destroy
    @sample_type = SampleType.find(params[:id])
    @sample_type.destroy

    respond_to do |format|
      format.html { redirect_to(sample_types_url) }
      format.xml  { head :ok }
    end
  end
end
