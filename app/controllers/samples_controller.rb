class SamplesController < ApplicationController

  before_filter :ensure_researcher, :except => [ 'show_log', 'participant_note', 'update_participant_note', 'mark_as_destroyed' ]
  skip_before_filter :ensure_enrolled, :except => [ 'participant_note', 'update_participant_note' ]
  skip_before_filter :ensure_latest_consent, :except => [ 'participant_note', 'update_participant_note' ]
  skip_before_filter :ensure_recent_safety_questionnaire, :except => [ 'participant_note', 'update_participant_note' ]

  # GET /samples
  # GET /samples.xml
  def index
    @samples = Sample.scoped.includes([:kit, :participant, :study])

    @samples = @samples.where('samples.owner_id = ? OR studies.creator_id = ?', current_user.id, current_user.id) unless current_user.is_admin?

    if params[:study_id]
      @samples = @samples.where('samples.study_id = ?', params[:study_id])
    end

    respond_to do |format|
      format.csv {
        buf = FasterCSV.generate(String.new, :force_quotes => true) do |csv|
          csv << %w(sample_id sample_url_code kit_sample_name kit_id kit_name participant_hex)
          @samples = @samples.includes(:kit_design_sample)
          @samples.each { |s|
            csv << [s.crc_id_s, s.url_code, s.kit_design_sample.name, s.kit.crc_id_s, s.kit.name, s.participant ? s.participant.hex : nil]
          }
        end
        forwhat = params[:study_id] ? "ForStudy#{params[:study_id]}" : ""
        send_data buf, {
          :filename    => "Samples#{forwhat}.csv",
          :type        => 'application/csv',
          :disposition => 'attachment'
        }
      }
      format.html {
        @samples = @samples.paginate(:page => params[:page] || 1, :per_page => 30)
      }
      format.json {
        respond_with(@samples,
                     :for => current_user,
                     :api_template => :researcher)
      }
    end
  end

  def receive
  end

  # GET /samples/m/:url_code
  def mobile
    # This url will be arrived at based on a QR code, printed on the sample.
    @sample = Sample.find_by_url_code(params[:url_code])

    return not_found if @sample.nil?

    if check_for_scan_context
      session[:scan_sample_url_code] = params[:url_code]
      if @sample.participant and @sample.owner and @sample.last_received
        return redirect_to session[:scan_context_path]
      else
        flash[:error] = "You seem to be processing a sample that has not been received yet."
        set_page_title
        return render :layout => "none"
      end
    else
      # No scan_context_path -- assume the current activity is "receive samples"
      mobile_receive
    end
  end

  def mobile_receive
    @sample = Sample.find_by_url_code(params[:url_code]) unless @sample

    return not_found if @sample.nil?

    check_for_scan_context

    # If the sample has a participant and is not yet owned by this researcher, mark it as such
    if @sample.participant.nil? then
      flash.delete(:notice)
      flash[:error]  = "Sample unclaimed"
    else
      flash.delete(:error)
      flash.delete(:notice)
      if @sample.owner != current_user then
        flash.delete(:error)
        flash[:notice]  = "Sample received"
        sample_received(@sample)
      end
    end

    # Log this
    SampleLog.new(:actor => current_user, :comment => "Sample received by researcher (scan)", :sample_id => @sample.id).save

    # Mobile friendly
    set_page_title
    render :action => :mobile, :layout => "none"
  end

  # POST /samples/m/:url_code/undo_reception
  def mobile_undo_reception
    @sample = Sample.find_by_url_code(params[:url_code])

    # If the sample is owned by this researcher, undo that
    if @sample.owner == current_user then
      @sample.owner = nil
      @sample.save!
    end

    # Log this
    SampleLog.new(:actor => current_user, :comment => "Undo: sample received by researcher (scan)", :sample_id => @sample.id).save

    # Mobile friendly
    flash.delete(:error)
    flash.delete(:notice)

    check_for_scan_context

    set_page_title
    render :action => :mobile, :layout => "none"
  end

  # POST /samples/1/destroyed
  def mark_as_destroyed
    @sample = Sample.find(params[:id])

    if current_user.is_unprivileged? and @sample.participant != current_user
      redirect_to unauthorized_user_url
      return
    end

    @sample.is_destroyed = Time.now()
    @sample.save()

    # Log this
    SampleLog.new(:actor => current_user, :comment => "Marked sample as destroyed", :sample_id => @sample.id).save

    flash[:notice]  = "Sample #{@sample.crc_id_s} marked as destroyed"

    redirect_to(kit_path(@sample.kit.id))
  end

  # GET /samples/1/log
  def show_log
    @sample = Sample.find(params[:id])
    @sample_log = SampleLog.where('sample_id = ?', @sample.id).sort { |a,b|
      cmp = b.created_at <=> a.created_at
      cmp = b.id <=> a.id if cmp == 0
      cmp
    }
    @page_title = "Sample Logs: #{@sample.crc_id_s} #{@sample.name}"

    if current_user.is_unprivileged? and @sample.participant != current_user
      redirect_to unauthorized_user_url
      return
    end

  end

  # GET /samples/1
  # GET /samples/1.xml
  def show
    @sample = Sample.find(params[:id])
    respond_with @sample, :api_template => :researcher
  end

   # POST /samples/1/received
  def received
    @sample = Sample.find(params[:id])

    sample_received(@sample)

    # Log this
    SampleLog.new(:actor => current_user, :comment => "Sample received by researcher", :sample_id => @sample.id).save

    redirect_to(kit_path(@sample.kit.id))
  end

  def receive_by_crc_id
    response = { :ok => false }
    @sample = Sample.find_by_crc_id(params[:crc_id])
    if @sample.nil?
      response[:message] = 'No sample has been issued with that ID number.'
    elsif @sample.owner.nil? or @sample.owner == @sample.participant or (@sample.last_mailed and !@sample.last_received)
      sample_received(@sample)
      SampleLog.new(:actor => current_user, :comment => "Sample received by researcher", :sample_id => @sample.id).save
      response[:ok] = true
      response[:message] = 'Sample marked as received.'
    elsif @sample.owner == current_user
      response[:ok] = true
      response[:message] = "You already received this sample at #{@sample.last_received}."
    elsif @sample.owner.is_researcher?
      response[:message] = "Sample owner (#{@sample.owner.full_name}) has not shipped this sample."
    else
      response[:message] = 'Sample owner (##{@sample.owner.id) has not shipped this sample.'
    end
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

  # GET /samples/new
  # GET /samples/new.xml
  def new
    @sample = Sample.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample }
    end
  end

  # GET /samples/1/participant_note
  def participant_note
    @sample = Sample.find(params[:id])

    if current_user.is_unprivileged? and @sample.participant != current_user
      redirect_to unauthorized_user_url
      return
    end
  end

  # PUT /samples/1/participant_note
  def update_participant_note
    @sample = Sample.find(params[:id])

    if current_user.is_unprivileged? and @sample.participant != current_user
      redirect_to unauthorized_user_url
      return
    end

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        format.html { redirect_to(@sample.kit, :controller => :kits, :notice => 'Participant note was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "participant_note" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
  end

  # POST /samples
  # POST /samples.xml
  def create
    @sample = Sample.new(params[:sample])

    respond_to do |format|
      if @sample.save
        format.html { redirect_to(@sample, :notice => 'Sample was successfully created.') }
        format.xml  { render :xml => @sample, :status => :created, :location => @sample }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /samples/1
  # PUT /samples/1.xml
  def update
    @sample = Sample.find(params[:id])

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        format.html { redirect_to(@sample, :notice => 'Sample was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /samples/1
  # DELETE /samples/1.xml
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy

    respond_to do |format|
      format.html { redirect_to(samples_url) }
      format.xml  { head :ok }
    end
  end

  private

  def sample_received(sample)
    sample.last_received = Time.now()
    sample.owner = current_user
    sample.save!
    # If the researcher has the sample, they have the kit
    kit = sample.kit
    if kit.owner != current_user
      KitLog.new(:actor => current_user, :comment => "Kit received", :kit_id => kit.id).save
      kit.last_received = Time.now
      kit.owner = current_user
      kit.save!
    end
  end

  def check_for_scan_context
    @have_scan_context = session[:scan_context_path] and session[:scan_context_gerund] and session[:scan_context_timestamp] > Time.now.to_i - 1800
  end

  def set_page_title
    @page_title = "Samples: #{@sample.crc_id_s} ({@sample.name})" if @sample
  end
end
