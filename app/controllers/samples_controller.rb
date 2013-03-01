class SamplesController < ApplicationController

  before_filter :ensure_researcher, :except => [ 'show', 'show_log', 'participant_note', 'update_participant_note', 'mark_as_destroyed', :index ]
  skip_before_filter :ensure_enrolled, :except => [ 'participant_note', 'update_participant_note' ]
  skip_before_filter :ensure_latest_consent, :except => [ 'participant_note', 'update_participant_note' ]
  skip_before_filter :ensure_recent_safety_questionnaire, :except => [ 'participant_note', 'update_participant_note' ]
  skip_before_filter :login_required, :only => [:index]
  skip_before_filter :ensure_active, :only => [:index]
  skip_before_filter :ensure_tos_agreement, :only => [:index]

  # GET /samples
  # GET /samples.xml
  def index
    @page_title = 'Specimens'
    @samples = Sample.scoped.
      includes([:kit, :participant, :study, :owner, :parent_samples]).
      visible_to(current_user)

    unless params[:include_derived_samples]
      @samples = @samples.
        where('parent_samples_samples.id is ?',nil)
    end

    if params[:study_id]
      @samples = @samples.where('samples.study_id = ?', params[:study_id])
    end

    respond_to do |format|
      format.csv {
        buf = FasterCSV.generate(String.new, :force_quotes => true) do |csv|
          csv << %w(sample_id sample_url_code kit_sample_name kit_id kit_name participant_hex material amount unit location)
          @samples = @samples.includes(:kit_design_sample)
          @samples.each { |s|
            privileged = current_user and (current_user.id == s.participant_id or
                                           current_user.id == s.owner_id or
                                           current_user.id == s.study.creator_id)
            csv << [s.crc_id_s,
                    (s.url_code if privileged),
                    s.kit_design_sample ? s.kit_design_sample.name : nil,
                    (privileged and s.kit) ? s.kit.crc_id_s : nil,
                    (privileged and s.kit) ? s.kit.name : nil,
                    s.participant ? s.participant.hex : nil,
                    s.material,
                    s.amount,
                    s.unit,
                    s.owner ? (s.owner.is_researcher? ? s.owner.researcher_affiliation : s.owner.hex) : nil
                   ]
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
        respond_with @samples
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
      if @sample.participant and not (@sample.owner and @sample.last_received)
        sample_received(@sample)
      end
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

    redirect_to(@sample.kit || @sample)
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

    if current_user.is_unprivileged? and @sample.participant != current_user
      redirect_to unauthorized_user_url
      return
    end

    respond_with @sample
  end

   # POST /samples/1/received
  def received
    @sample = Sample.find(params[:id])

    sample_received(@sample)

    # Log this
    SampleLog.new(:actor => current_user, :comment => "Sample received by researcher", :sample_id => @sample.id).save

    redirect_to(@sample.kit || @sample)
  end

  def receive_multiple_confirm
    load_selection
    if params[:confirm_url_codes]
      @selected = params[:confirm_url_codes].
        reject { |url_code,checked| checked.to_s != '1' }
    else
      @selected = {}
    end
    @samples = Sample.
      where('url_code in (?)', @selected.keys).
      select { |sample|
      # just make sure the database is being case-sensitive
      @selected[sample.url_code].to_s == '1'
    }
    @received_samples = []
    @plated_samples = []
    @plates = []
    @samples.each { |sample|
      if sample.owner != current_user
        @received_samples << sample
        sample_received(sample)
        SampleLog.new(:actor => current_user, :comment => "Sample received by researcher", :sample_id => sample.id).save
      end
      si = @sample_info[sample.id]
      if si and si[:plate]
        @plated_samples << sample
        @plates << si[:plate]
        si[:plate].transfer_sample_to_position(sample, si[:plate_layout_position], current_user)
      end
    }
    if @received_samples.empty? and @plated_samples.empty?
      flash[:warning] = "No samples were received.  Nothing happened at all."
    else
      s = ""
      if !@received_samples.empty?
        s << "Received #{@received_samples.size} sample#{'s' if @received_samples.size > 1}"
        if @received_samples.size < 16
          s << ": #{@received_samples.collect(&:url_code).join(', ')}"
        end
        s << ". "
      end
      if !@plated_samples.empty?
        s << "Transferred #{@plated_samples.size} sample#{'s' if @plated_samples.size > 1} to plate#{'s' if @plates.uniq.size > 1} #{@plates.uniq.collect(&:crc_id_s).join(', ')}."
      end
      flash[:notice] = s
    end
    redirect_to(receive_sample_path)
  end

  before_filter :load_selection, :only => :receive_multiple
  def receive_multiple
    @hack_is_coriell = current_user &&
      current_user.researcher_affiliation &&
      current_user.researcher_affiliation.match(/Coriell/i)

    @samples = []
    @samples |= Sample.
      where('url_code in (?)', params[:url_codes].split(',')).
      includes(:original_kit_design_sample).
      includes(:owner).
      includes(:kit).
      includes(:participant) unless params[:url_codes] == 'FILE'
    @samples |= Sample.
      where('id in (?)', @selection.target_ids).
      includes(:original_kit_design_sample).
      includes(:owner).
      includes(:kit).
      includes(:participant) if @selection

    @reveal_participant = current_user && current_user.researcher &&
      (@hack_is_coriell || current_user.researcher_onirb)

    @samples.sort! { |a,b|
      if @sample_info and @sample_info[a.id] and @sample_info[b.id]
        @sample_info[a.id][:row_number] <=> @sample_info[b.id][:row_number]
      elsif a.kit and b.kit and a.kit != b.kit
        a.kit.name <=> b.kit.name
      else
        a.id - b.id
      end
    }

    @default_checked_hack = {}
    if @hack_is_coriell
      @samples.each do |sample|
        @default_checked_hack[sample.url_code] =
        (sample.name and sample.name.match(/ACD/)) ||
        (sample.original_kit_design_sample and
         sample.original_kit_design_sample.device.match(/ACD/))
      end
    end
  end

  def receive_by_crc_id
    response = { :ok => false }
    @search_codes = params[:crc_id].strip.split(/[ ,;\n]+/)

    matched_samples = Sample.
      where('url_code in (?) or crc_id in (?)', @search_codes, @search_codes)
    matched_kits = Kit.
      includes(:samples).
      where('name in (?) or url_code in (?) or crc_id in (?)', @search_codes, @search_codes, @search_codes)
    @samples = [matched_samples,
                matched_kits.collect(&:samples)
               ].flatten

    if @samples.size == 0
      response[:message] = 'No sample or kit has been issued with that ID.'
    elsif @samples.size > 1 or
        !matched_kits.empty? or
        @search_codes.size > 1
      # If there's any possibility that the user is about to -- or is
      # expecting to -- receive multiple samples...
      response[:redirect_to] = receive_multiple_samples_path(@samples.collect(&:url_code).join(','))
      response[:message] = 'Proceeding to the sample selection page...'
      response[:ok] = true
    else
      @sample = @samples.first
      if @sample.owner.nil? or @sample.owner == @sample.participant or (@sample.last_mailed and !@sample.last_received)
        sample_received(@sample)
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
        format.html { redirect_to((@sample.kit || @sample), :controller => :kits, :notice => 'Participant note was successfully updated.') }
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
    sample.receive! current_user
  end

  def check_for_scan_context
    @have_scan_context = session[:scan_context_path] and session[:scan_context_gerund] and session[:scan_context_timestamp] > Time.now.to_i - 1800
  end

  def set_page_title
    @page_title = "Samples: #{@sample.crc_id_s} ({@sample.name})" if @sample
  end

  def load_selection
    super
    @sample_info = Sample.load_selection_info(@selection)
  end

end
