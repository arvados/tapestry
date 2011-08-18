class SamplesController < ApplicationController

  before_filter :ensure_researcher

  # GET /samples
  # GET /samples.xml
  def index
    if current_user.is_admin? then
      @samples = Sample.all
    else
      @samples = Sample.where('originator_id = ?',current_user.id)
    end
    @samples = @samples.paginate(:page => params[:page] || 1, :per_page => 30)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @samples }
    end
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
    SampleLog.new(:actor_id => @current_user.id, :comment => "Sample received by researcher (scan)", :sample_id => @sample.id).save

    # Mobile friendly
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
    SampleLog.new(:actor_id => @current_user.id, :comment => "Undo: sample received by researcher (scan)", :sample_id => @sample.id).save

    # Mobile friendly
    flash.delete(:error)
    flash.delete(:notice)

    check_for_scan_context

    render :action => :mobile, :layout => "none"
  end

  # GET /samples/1/log
  def show_log
    @sample = Sample.find(params[:id])
    @sample_log = SampleLog.where('sample_id = ?', @sample.id).sort { |a,b| b.updated_at <=> a.updated_at }
  end

  # GET /samples/1
  # GET /samples/1.xml
  def show
    @sample = Sample.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sample }
    end
  end

   # POST /samples/1/received
  def received
    @sample = Sample.find(params[:id])

    sample_received(@sample)

    # Log this
    SampleLog.new(:actor_id => @current_user.id, :comment => "Sample received by researcher", :sample_id => @sample.id).save

    redirect_to(kit_path(@sample.kit.id))
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
    kit.last_received = Time.now()
    kit.owner = current_user
    kit.save!
  end

  def check_for_scan_context
    @have_scan_context = session[:scan_context_path] and session[:scan_context_gerund] and session[:scan_context_timestamp] > Time.now.to_i - 1800
  end
end
