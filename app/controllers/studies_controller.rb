class StudiesController < ApplicationController
  load_and_authorize_resource :except => [:map, :users, :update_user_status, :show, :verify_participant_id, :clickthrough_to, :show_third_party]

  skip_before_filter :ensure_enrolled, :except => [:show, :claim, :show_third_party]
  skip_before_filter :ensure_latest_consent, :except => [:show, :claim, :show_third_party]
  skip_before_filter :ensure_recent_safety_questionnaire, :except => [:show, :claim, :show_third_party]

  before_filter :ensure_researcher
  skip_before_filter :ensure_researcher, :only => [:show, :claim, :index, :show_third_party]

  skip_before_filter :login_required, :only => [:verify_participant_id]
  skip_before_filter :ensure_tos_agreement, :only => [:verify_participant_id]
  skip_before_filter :ensure_researcher, :only => [:verify_participant_id]
  skip_before_filter :ensure_researcher, :only => :clickthrough_to

  def index
    redirect_to page_path( :collection_events, :anchor => 'kits' ) if current_user and !current_user.researcher
    @studies = Study.all if current_user and current_user.is_admin?
    @studies = @studies.includes(:kits) if @studies.respond_to? :includes
  end

  # GET /studies/1/map
  def map
    @study = Study.find(params[:id])
    authorize! :read, @study

    claimed_kit_addrs = @study.kits.claimed.includes(:participant => :shipping_address).collect { |x| x.participant.shipping_address.id }
    returned_kit_addrs = @study.kits.returned.includes(:participant => :shipping_address).collect { |x| x.participant.shipping_address.id }
    received_kit_addrs = @study.kits.received.includes(:participant => :shipping_address).collect { |x| x.participant.shipping_address.id }

    # The call to compact will filter out nil elements
    @json = @study.study_participants.accepted.includes(:user => {:shipping_address => :user}).collect { |p| p.user.shipping_address }.compact.to_gmaps4rails do |shipping_address, marker|
      # green: claimed
      # blue: returned
      # brown: received by researcher
      # Kit is created / possibly shipped. We currently do not keep track of which addresses kits are shipped to so
      # we can not distinguish between these 2 states.
      @picture = view_context.image_path('yellow.png')
      # Claimed by participant
      @picture = view_context.image_path('green.png') if claimed_kit_addrs.include?(shipping_address.id)
      # Returned to researcher
      @picture = view_context.image_path('blue.png') if returned_kit_addrs.include?(shipping_address.id)
      # Received by researcher
      @picture = view_context.image_path('brown.png') if received_kit_addrs.include?(shipping_address.id)
      marker.picture({
                        :picture => @picture,
                        :width =>  23,
                        :height => 34,
                     })
      # There is a marker.title option but it does strange things as of gmaps4rails v1.3.0
      marker.json("\"title\": \"#{shipping_address.user.hex}\"")
    end

    flash[:notice] = "No approved participants with valid shipping addresses were found" if @json == '[]'

    render :layout => APP_CONFIG['application_layout_gmaps']
  end

  # GET /studies/claim
  def claim
    # No need to do anything special here for Cancan, because there is no object involved in this action.
    # This is just a static page. TODO: move to the pages controller.
  end

  # GET /studies/1/users
  def users
    load_selection
    authorize! :read, @study

    @participants = StudyParticipant.
      includes([:study, {:user => {:kits => :kit_logs}}]).
      where('study_participants.id in (?)', @participants.collect(&:id))

    @all_participants = @study.study_participants.real
    if @study.is_third_party
      @sorted_participants = @participants.sort_by { |p| p.user.app_token("Study##{@study.id}") }
    else
      @sorted_participants = @participants.sort_by { |p| p.user.full_name }
    end
    study_participant_info

    @last_kit_for_each_participant = @participants.collect do |p|
      p.claimed_kit_sent_at(p.kit_last_sent_at)[0]
    end
    @kit_status_count = Kit.status_counts(@last_kit_for_each_participant.compact)
    @kit_status_count << ['none', @last_kit_for_each_participant.select(&:nil?).size]

    respond_to do |format|
      format.html
      format.csv {
        send_data csv_for_study(@study,params[:type]), {
          :filename    => "participants_for_study#{@study.id}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv",
          :type        => 'application/csv',
          :disposition => 'attachment'
        }
      }
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
      redirect_to(page_path( :collection_events ))
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @studies }
    end
  end

  def show_third_party
    @study = Study.find(params[:id])
  end

  def new
    @study = Study.new
    @study.participation_url = 'http://' if request.env['PATH_INFO'].match(/third_party/)
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
      # These fields are immutable once the study is approved
      params[:study].delete(:name)
      params[:study].delete(:participant_description)
      params[:study].delete(:is_third_party)
      params[:study].delete(:participation_url)
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

  def accept_interested_selected
    load_selection
    authorize! :read, @study

    n = 0
    @selected_study_participants.each do |sp|
      if sp.status == StudyParticipant::STATUSES['interested']
        sp.update_attributes! :status => StudyParticipant::STATUSES['accepted']
        n += 1
      end
    end
    flash[:notice] = "Accepted #{n} participants."
    redirect_to(params[:return_to] || @study)
  end

  def sent_kits_to_selected
    load_selection
    authorize! :read, @study

    if @selected_study_participants.reject { |sp| sp.status == StudyParticipant::STATUSES['accepted'] }.size > 0
      flash[:error] = "Error: Some selected participants are not accepted into this study."
      return redirect_to(params[:return_to] || @study)
    end

    comment = "A collection kit was mailed (##{@study.id} #{@study.name})"
    default_sent_at = Time.now
    n = 0
    ActiveRecord::Base.transaction do
      @selected_study_participants.each do |sp|
        sp_info = study_participant_info[sp.id]
        log_info = OpenStruct.new(:kit_sent_at => sp_info[:kit_last_sent_at],
                                  :news_feed_date => sp_info[:kit_last_sent_at],
                                  :tracking_id => sp_info[:tracking_id],
                                  :address => sp_info[:address])
        sent_at = log_info.kit_sent_at || default_sent_at
        UserLog.new(:user => sp.user,
                    :controlling_user => current_user,
                    :comment => comment,
                    :user_comment => comment,
                    :info => log_info).save!
        sp.update_attributes! :kit_last_sent_at => sent_at
        n += 1
      end
    end
    flash[:notice] = "Logged that kits have been sent to #{n} participants."
    n_notified = 0
    @selected_study_participants.each do |sp|
      sp_info = study_participant_info[sp.id]
      unless sp_info[:skip_notification]
        UserMailer.kit_sent_notification(sp, sp_info).deliver
        n_notified += 1
      end
    end
    flash[:notice] << "  #{n_notified} notification#{'s' if n_notified != 1} sent."
    redirect_to(params[:return_to] || @study)
  end

  def verify_participant_id
    study = Study.where('id = ?', params[:id].to_i).first
    if params[:id].to_i > 0 and
        study and study.is_third_party and
        params[:app_token] == '00000000000000000000000000000000'
      return render :json => { :valid => true }
    end
    StudyParticipant.
      where('study_id = ?', params[:id]).
      includes(:user).
      each do |sp|
      if sp.user.app_token("Study##{sp.study_id}") == params[:app_token]
        return render :json => { :valid => true }
      end
    end
    return render :json => { :valid => false }, :status => 404
  end

  def clickthrough_to
    @study = Study.third_party.find(params[:id])
    @sp = StudyParticipant.where('study_id=? and user_id=?',
                                 @study.id, current_user.id).first
    @sp ||= StudyParticipant.new(:study => @study,
                                 :user => current_user)
    @sp.update_attributes :status => StudyParticipant::STATUSES['interested']
    @sp.save!
    redirect_to @study.personalized_participation_url(current_user)
  end

  protected

  def load_selection
    super
    @study = Study.includes(:study_participants).find(params[:id])
    if @selection
      # select participants by supplied user IDs, regardless of enrolled/suspended state
      ids = @study.study_participants.real.collect(&:user_id) & @selection.target_ids
      @participants = @study.study_participants.real.includes(:user).where('user_id in (?)', ids)
    else
      # select all participants who are still enrolled, not_suspended
      @participants = @study.study_participants.enrolled_and_active.includes(:user)
    end
    @selected_study_participants = @participants
  end

  def study_participant_info
    @study_participant_info = {} if !@selection
    return @study_participant_info if @study_participant_info

    found_usa_dates = 0
    found_native_dates = 0
    usa_date_format = '%m/%d/%Y %H:%M %p'

    timestamp_column = @selection.spec_table_column_with_most do |x|
      unless x.respond_to?(:match) && x.match(/\d+-\d+-\d+|\d+\/\d+\/\d+/)
        nil
      else
        begin
          found_usa_dates += 1 if Time.strptime(x, usa_date_format)
        rescue
          found_native_dates += 1 if Time.parse(x) rescue nil
        end
      end
    end

    address_column = @selection.spec[:table][0].index { |x| x && x.match(/\baddress\b/i) } rescue nil

    tracking_id_column = @selection.spec[:table][0].index { |x| x && x.match(/^tracking/i) } rescue nil
    tracking_id_column ||= @selection.spec_table_column_with_most do |x|
      x.respond_to?(:match) && x.match(/^9400\d+0000000$/)
    end

    @study_participant_info = {}
    @participants.each do |study_participant|
      info = {}
      @selection.spec_table_rows_for_all_targets[study_participant.user_id].each do |spec_table_row|
        if found_usa_dates > found_native_dates
          t = Time.strptime(spec_table_row[timestamp_column+1], usa_date_format) rescue nil
        else
          t = Time.parse(spec_table_row[timestamp_column+1]) rescue nil
        end
        # Most recent timestamp in all rows referring to this user
        if t
          info[:kit_last_sent_at] = t if !info[:kit_last_sent_at] || t > info[:kit_last_sent_at]
        end

        # Number of rows referring to this user
        info[:n_rows] ||= 0
        info[:n_rows] += 1

        # Courier tracking id
        info[:tracking_id] = spec_table_row[tracking_id_column+1] if tracking_id_column

        # Shipping address used
        info[:address] = spec_table_row[address_column+1] if include_section?(Section::SHIPPING_ADDRESS) && address_column
      end

      if info[:kit_last_sent_at] and info[:kit_last_sent_at] < 14.days.ago
        info[:skip_notification] = true
      end

      @study_participant_info[study_participant.id] = info
    end
    @study_participant_info
  end

end
