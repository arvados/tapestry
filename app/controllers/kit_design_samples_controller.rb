class KitDesignSamplesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

  # GET /kit_design_samples
  # GET /kit_design_samples.xml
  def index
    @kit_design_samples = KitDesignSample.all.sort { |a,b| a.name <=> b.name }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kit_design_samples }
    end
  end

  # GET /kit_design_samples/1
  # GET /kit_design_samples/1.xml
  def show
    @kit_design_sample = KitDesignSample.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @kit_design_sample }
    end
  end

  # GET /kit_design_samples/new
  # GET /kit_design_samples/new.xml
  def new
    @kit_design_sample = KitDesignSample.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kit_design_sample }
    end
  end

  # GET /kit_design_samples/1/edit
  def edit
    @kit_design_sample = KitDesignSample.find(params[:id])
  end

  # POST /kit_design_samples
  # POST /kit_design_samples.xml
  def create
    @kit_design_sample = KitDesignSample.new(params[:kit_design_sample])

    respond_to do |format|
      if @kit_design_sample.save
        flash[:notice] = 'Kit design sample was successfully created.'
        format.html { redirect_to(kit_design_samples_url) }
        format.xml  { render :xml => @kit_design_sample, :status => :created, :location => @kit_design_sample }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kit_design_sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kit_design_samples/1
  # PUT /kit_design_samples/1.xml
  def update
    @kit_design_sample = KitDesignSample.find(params[:id])

    respond_to do |format|
      if @kit_design_sample.update_attributes(params[:kit_design_sample])
        flash[:notice] = 'Kit design sample was successfully created.'
        format.html { redirect_to(kit_design_samples_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kit_design_sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kit_design_samples/1
  # DELETE /kit_design_samples/1.xml
  def destroy
    @kit_design_sample = KitDesignSample.find(params[:id])
    @kit_design_sample.destroy

    respond_to do |format|
      format.html { redirect_to(kit_design_samples_url) }
      format.xml  { head :ok }
    end
  end
end
