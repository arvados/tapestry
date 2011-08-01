class KitDesignsController < ApplicationController

  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher

  # GET /kit_designs/new
  # GET /kit_designs/new.xml
  def new
    @kit_design = KitDesign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kit_design }
    end
  end

  # GET /kit_designs/1/edit
  def edit
    @kit_design = KitDesign.find(params[:id])
  end

  # POST /kit_designs
  # POST /kit_designs.xml
  def create
    @kit_design = KitDesign.new(params[:kit_design])

    # Override this field just in case; it comes in as a hidden form field
    @kit_design.owner = current_user

    respond_to do |format|
      if @kit_design.save
        flash[:notice] = 'Kit design was successfully created.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
        format.xml  { render :xml => @kit_design, :status => :created, :location => @kit_design }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kit_design.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kit_designs/1
  # PUT /kit_designs/1.xml
  def update
    @kit_design = KitDesign.find(params[:id])

    p = Hash.new
    if not @kit_design.editable? then
      # When frozen, only the errata field can be modified
      p['errata'] = params[:kit_design]['errata']
    else
      p = params[:kit_design]
    end

    # Override this field just in case; it comes in as a hidden form field
    @kit_design.owner = current_user

    respond_to do |format|
      if @kit_design.update_attributes(p)
        flash[:notice] = 'Kit design was successfully updated.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kit_design.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kit_designs/1
  # DELETE /kit_designs/1.xml
  def destroy
    @kit_design = KitDesign.find(params[:id])

    if not @kit_design.editable? then
      flash[:error] = 'This kit design is frozen; it can not be deleted.'
      redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools')
      return
    end

    @kit_design.destroy

    respond_to do |format|
      format.html { redirect_to(kit_designs_url) }
      format.xml  { head :ok }
    end
  end
end
