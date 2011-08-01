class KitDesignSamplesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

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
    flash.delete(:error)
    @kit_design_sample = KitDesignSample.new(params[:kit_design_sample])

    begin
      @sti = SampleType.find(params[:sample_type_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Please select a sample type to base this kit design sample on'
      respond_to do |format|
        format.html { render :action => "new" }
      end
      return
    end

    @kit_design_sample.tissue = @sti.tissue_type.name
    @kit_design_sample.device = @sti.device_type.name
    @kit_design_sample.description = @sti.description
    @kit_design_sample.target_amount = @sti.target_amount
    @kit_design_sample.unit = @sti.unit.name

    respond_to do |format|
      if @kit_design_sample.save
        flash[:notice] = 'Kit design sample was successfully created.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
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

    p = Hash.new
    if not @kit_design_sample.editable? then
      # When frozen, only the errata field can be modified
      p['errata'] = params[:kit_design_sample]['errata']
    else
      p = params[:kit_design_sample]
    end

    respond_to do |format|
      if @kit_design_sample.update_attributes(p)
        flash[:notice] = 'Kit design sample was successfully updated.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
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

    if (not @kit_design_sample.editable?) then
        flash[:error] = 'This kit design sample is frozen; it can not be deleted.'
        redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools')
        return
    end

    @kit_design_sample.destroy

    respond_to do |format|
      format.html { redirect_to(kit_design_samples_url) }
      format.xml  { head :ok }
    end
  end
end
