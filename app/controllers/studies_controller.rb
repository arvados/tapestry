class StudiesController < ApplicationController
  load_and_authorize_resource :except => [:map, :users, :update_user_status, :show]

  skip_before_filter :ensure_enrolled, :except => [:show, :claim]
  skip_before_filter :ensure_latest_consent, :except => [:show, :claim]
  skip_before_filter :ensure_recent_safety_questionnaire, :except => [:show, :claim]

  before_filter :ensure_researcher

  skip_before_filter :ensure_researcher, :only => [:show, :claim]

  # GET /studies/1/map
  def map
    @study = Study.find(params[:id])
    authorize! :read, @study

    # The call to compact will filter out nil elements
    @json = @study.study_participants.accepted.collect { |p| p.user.shipping_address }.compact.to_gmaps4rails do |shipping_address, marker|
      # green: claimed
      # blue: returned
      # brown: received by researcher
      # Kit is created / possibly shipped. We currently do not keep track of which addresses kits are shipped to so
      # we can not distinguish between these 2 states.
      @picture = '/images/yellow.png'
      # Claimed by participant
      @picture = '/images/green.png' if @study.kits.claimed.collect { |x| x.participant.shipping_address.id }.include?(shipping_address.id)
      # Returned to researcher
      @picture = '/images/blue.png' if @study.kits.returned.collect { |x| x.participant.shipping_address.id }.include?(shipping_address.id)
      # Received by researcher
      @picture = '/images/brown.png' if @study.kits.received.collect { |x| x.participant.shipping_address.id }.include?(shipping_address.id)
      marker.picture({
                        :picture => @picture,
                        :width =>  23,
                        :height => 34,
                     })
      # There is a marker.title option but it does strange things as of gmaps4rails v1.3.0
      marker.json("\"title\": \"#{shipping_address.user.hex}\"")
    end

    flash[:notice] = "No approved participants with valid shipping addresses were found" if @json == '[]'

    render :layout => "gmaps"
  end

  # GET /studies/claim
  def claim
    # No need to do anything special here for Cancan, because there is no object involved in this action.
    # This is just a static page. TODO: move to the pages controller.
  end

  # GET /studies/1/users
  def users
    @study = Study.find(params[:id])
    authorize! :read, @study
    @all_participants = @study.study_participants.real
    @participants = @study.study_participants.real.sort { |a,b| a.user.full_name <=> b.user.full_name }
    respond_to do |format|
      format.html
      format.csv { send_data csv_for_study(@study,params[:type]), {
                     :filename    => 'StudyUsers.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

  def update_user_status
    @study = Study.find(params[:study_id])
    @user = User.find(params[:user_id])
    authorize! :update, @study

    @status = StudyParticipant::STATUSES[params[:status]]

    @sp = @study.study_participants.where('user_id = ?',@user.id).first
    @sp.status = @status
    @sp.save
    redirect_to(study_users_path(@study))
  end

  # GET /studies/1
  # GET /studies/1.xml
  # This page is referenced from the public profile (only). Cancan is not involved
  # in guarding access to it.
  def show
    @study = Study.find(params[:id])

    if not current_user.is_admin? and @study.approved == nil then
      # Only approved studies should be available here for ordinary users
      redirect_to('/pages/studies')
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @studies }
    end
  end

  # POST /studies
  # POST /studies.xml
  def create
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
    if not current_user.is_admin?
      # Override this field just in case; it comes in as a hidden form field
      @study.researcher = current_user
    end

    # These fields are immutable for the researcher
    params[:study].delete(:approved)
    params[:study].delete(:irb_associate_id)

    if (@study.approved) then
      # Study name and participant description fields are immutable once the study is approved
      params[:study].delete(:name)
      params[:study].delete(:participant_description)
    end

    @open = params[:study].delete(:open)
    if ((@study.open != @open) and (@study.open == false)) then
      @study.date_opened = Time.now()
    end
    @study.open = @open

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
    @study.destroy

    respond_to do |format|
      format.html { redirect_to(studies_url) }
      format.xml  { head :ok }
    end
  end
end
