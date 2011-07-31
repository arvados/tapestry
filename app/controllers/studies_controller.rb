class StudiesController < ApplicationController

  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher
  skip_before_filter :ensure_researcher, :only => [:show]

  # GET /studies/1
  # GET /studies/1.xml
  def show
    @study = Study.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @studies }
    end
  end

  # GET /studies/new
  # GET /studies/new.xml
  def new
    @study = Study.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @study }
    end
  end

  # GET /studies/1/edit
  def edit
    @study = Study.find(params[:id])
  end

  # POST /studies
  # POST /studies.xml
  def create
    @study = Study.new(params[:study])

    # Override this field just in case; it comes in as a hidden form field
    @study.researcher = current_user

    # These fields are immutable for the researcher
    params[:study].delete(:approved)
    params[:study].delete(:irb_associate_id)

    respond_to do |format|
      if @study.save
        flash[:notice] = 'Study was successfully created.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
        format.xml  { render :xml => @study, :status => :created, :location => @study }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @study.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /studies/1
  # PUT /studies/1.xml
  def update
    @study = Study.find(params[:id])

    # Override this field just in case; it comes in as a hidden form field
    @study.researcher = current_user

    # These fields are immutable for the researcher
    params[:study].delete(:approved)
    params[:study].delete(:irb_associate_id)

    if (@study.approved) then
      # Study name and participant description fields are immutable once the study is approved
      params[:study].delete(:name)
      params[:study].delete(:participant_description)
    end

    respond_to do |format|
      if @study.update_attributes(params[:study])
        flash[:notice] = 'Study was successfully updated.'
        format.html { redirect_to(:controller => 'pages', :action => 'show', :id => 'researcher_tools') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @study.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /studies/1
  # DELETE /studies/1.xml
  def destroy
    @study = Study.find(params[:id])
    @study.destroy

    respond_to do |format|
      format.html { redirect_to(studies_url) }
      format.xml  { head :ok }
    end
  end
end
