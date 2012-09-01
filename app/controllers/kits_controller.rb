class KitsController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher, :except => ['claim', 'confirm_claim', 'returned', 'show']

  # GET /kit/claim
  def claim
    @kit = Kit.where('last_mailed is not ? and participant_id is ? and name = ?',nil,nil,params[:name]).first
    if (@kit.nil?) then
        flash[:error] = "We do not have a record of a kit with this name. Please double check the spelling. If you are certain the spelling is correct, please " + 
                        ActionController::Base.helpers.link_to('contact us', new_message_path) + "."
        redirect_to(study_claim_kit_url)
        return
    end
  end

  # POST /kit/1/confirm_claim
  def confirm_claim
    @kit = Kit.find(params[:id])

    if not params.has_key?('agreed') then
        flash[:error] = 'Please agree to the terms of sample collection.'
        redirect_to(:controller => 'kits', :action => 'claim', :name => @kit.name)
        return
    end

    @kit.last_received = Time.now()
    @kit.participant = current_user
    @kit.owner = current_user
    @kit.save

    @kit.samples.each do |s|
      s.last_received = Time.now()
      s.participant = current_user
      s.owner = current_user
      s.save
      SampleLog.new(:actor => current_user, :comment => 'Sample received by participant', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor => current_user, :comment => 'Kit received by participant', :kit_id => @kit.id).save
    current_user.log("Kit #{@kit.name} (#{@kit.id}) received",nil,request.remote_ip,"Kit #{@kit.name} received")

    redirect_to(:controller => 'pages', :action => 'show', :id => 'collection_events' )
  end

  # POST /kit/1/returned
  def returned
    @kit = Kit.find(params[:id])

    if (@kit.participant != current_user) then
        flash[:error] = 'You do not have access to this kit'
        redirect_to(:controller => 'pages', :action => 'show', :id => 'collection_events')
        return
    end

    @kit.last_mailed = Time.now()
    # Nobody 'owns' the kit at the moment
    @kit.owner = nil
    @kit.save

    @kit.samples.each do |s|
      s.last_mailed = Time.now()
      s.owner = nil
      s.save
      SampleLog.new(:actor => current_user, :comment => 'Sample returned to researcher', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor => current_user, :comment => 'Kit returned to researcher', :kit_id => @kit.id).save
    current_user.log("Kit #{@kit.name} (#{@kit.id}) returned to researcher",nil,request.remote_ip,"Kit #{@kit.name} returned to researcher")

    redirect_to(:controller => 'pages', :action => 'show', :id => 'collection_events')
  end

   # POST /kits/1/sent
  def sent
    @kit = Kit.find(params[:id])
    @kit.send_to_participant!(current_user)
    redirect_to(:controller => 'kits', :action => 'index')
  end

  # POST /kits/sent_selected
  def sent_selected
    load_selection
    Kit.transaction do
      already_shipped = @selected_kits.select { |x| x.shipper or x.participant }
      if already_shipped.empty?
        @selected_kits.each do |k|
          k.send_to_participant!(current_user)
        end
        flash[:notice] = "Marked #{@selected_kits.size} kits as sent."
      else
        flash[:error] = "Action cancelled because #{already_shipped.size} of the selected kits have already been sent to participants."
      end
    end
    redirect_to (params[:return_to] or kits_path)
  end

  def select_name_range
    @selected_kits = []
    range = params[:name_range]
    return if !range or !range.respond_to? :[]
    if range[:a] == '' and range[:b] == ''
      @selected_kits = @all_kits
      return
    end
    a = Kit.where('? in (name,url_code,crc_id)', range[:a]).first
    b = Kit.where('? in (name,url_code,crc_id)', range[:b]).first
    if b and !a and range[:a] == ''
      a = Kit.where('study_id=?', b.study_id).order(:id).first
    elsif !a or (a.originator_id != current_user.id and !current_user.is_admin?)
      flash[:error] = "Invalid range: Kit '#{range[:a]}' not found."
      return
    end
    if a and !b and range[:b] == ''
      b = Kit.where('study_id=?', a.study_id).order(:id).last
    elsif !b or (b.originator_id != current_user.id and !current_user.is_admin?)
      flash[:error] = "Invalid range: Kit '#{range[:b]}' not found."
      return
    end
    if a.study_id != b.study_id
      flash[:error] = "Invalid range: Kits '#{a.name}' (#{a.crc_id_s}) and '#{b.name}' (#{b.crc_id_s}) do not belong to the same study."
      return
    end
    if a.id > b.id
      a,b = b,a
    end
    @where = ['id >= ? and id <= ? and study_id=?', a.id, b.id, a.study_id]
    @selected_kits = Kit.where(*@where)
    @selected_kits_description = "between '#{a.name}' (#{a.crc_id_s}) and '#{b.name}' (#{b.crc_id_s}) from '#{a.study.name}'"
    @selection = Selection.new(:spec => { :where => @where },
                               :targets => @selected_kits.collect(&:id))
    @selection.save
  end
  
  # GET /kits
  # GET /kits.xml
  def index
    load_selection
    if current_user.is_admin?
      @all_kits = Kit.where('1')
    else
      @all_kits = Kit.where('originator_id = ?',current_user.id)
    end
    if params[:study_id]
      @all_kits = @all_kits.where('study_id = ?', params[:study_id])
    end
    @all_kits = @all_kits.includes([:participant, :owner, :originator, :shipper, :kit_design, :study])
    select_name_range if params[:name_range]
    if @selection
      @kits = @selected_kits
      if !@selected_kits_description
        n_studies = @selected_kits.collect(&:study_id).uniq.count
        @selected_kits_description = "from #{n_studies} #{n_studies==1?'study':'studies'}"
      end
    else
      @kits = @all_kits
    end

    @kit_status_count = @kits.inject({}) { |h,k|
      h[k.short_status] ||= 0
      h[k.short_status] += 1
      h
    }.collect { |status,n|
      [status, n]
    }.sort_by { |status,n|
      Kit::STATUSES[status][0]
    }

    respond_to do |format|
      format.html {
        @kits = @kits.paginate(:page => params[:page] || 1, :per_page => 30)
      }
      format.xml  {
        render :xml => @kits
      }
      format.json {
        respond_with @kits.sort_by(&:id), :max_per_page => -1
      }
      format.csv {
        @kits = @kits.includes(:kit_logs => :actor)
        buf = FasterCSV.generate(String.new, :force_quotes => true) do |csv|
          csv << Kit.as_csv_header_row.unshift('sequence')
          seq = 0
          @kits.each do |k|
            csv << k.as_csv_row.unshift(seq += 1)
          end
        end
        prefix = @selection ? 'Selected' : ''
        forwhat = params[:study_id] ? "ForStudy#{params[:study_id]}" : ""
        send_data buf, {
          :filename    => "#{prefix}Kits#{forwhat}-#{Time.now.strftime '%Y%m%d%H%M%S'}.csv",
          :type        => 'application/csv',
          :disposition => 'attachment'
        }
      }
    end
  end

  # GET /kits/1/log
  def show_log
    @kit = Kit.find(params[:id])
    @kit_log = KitLog.where('kit_id = ?', @kit.id).sort { |a,b|
      cmp = b.created_at <=> a.created_at
      cmp = b.id <=> a.id if cmp == 0
      cmp
    }
  end

  # GET /kits/1
  # GET /kits/1.xml
  def show
    @kit = Kit.find(params[:id])
    @samples = @kit.samples

    if current_user.is_unprivileged? then
      if @kit.participant != current_user
        redirect_to unauthorized_user_url
        return
      end
      render :action => "show_user"
    else
      render
    end
  end

  # GET /kits/new
  # GET /kits/new.xml
  def new
    @kit = Kit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kit }
    end
  end

  # GET /kits/1/edit
  def edit
    @kit = Kit.find(params[:id])
  end

  def create_many
    n_created = 0
    howmany = params[:number_of_kits_to_create].to_i
    (1..howmany).each do
      @kit = Kit.new(params[:kit].merge(:name => UnusedKitName.random.name))
      @kit.originator = current_user
      @kit.owner = current_user
      @kit.crc_id = Kit.generate_verhoeff_number(@kit)
      @kit.url_code = Kit.generate_url_code(@kit)
      if @kit.save
        n_created += 1
        if not UnusedKitName.find_by_name(@kit.name).nil? then
          UnusedKitName.find_by_name(@kit.name).destroy
        end
        KitLog.new(:actor => current_user, :comment => 'Kit created', :kit_id => @kit.id).save
      else
        if n_created > 0
          # It's important to convey that some kits *did* get created
          # (if any) before the error was encountered.  The following
          # message shows up as "Id (after ...)".  There must be a
          # better way...
          @kit.errors.add :id, "(after creating #{n_created} of #{howmany} kits)"
        end
        params[:number_of_kits_to_create] = (howmany - n_created).to_s
        render :action => "new"
        return
      end
    end
    flash[:notice] = "Created #{n_created} kits."
    redirect_to(:controller => 'kits', :action => 'index')
  end

  # POST /kits
  # POST /kits.xml
  def create
    return create_many if params[:number_of_kits_to_create] != '1'

    @kit = Kit.new(params[:kit])

    # This user is the originator for the kit
    @kit.originator = current_user
    # And has current possession of it
    @kit.owner = current_user

    @kit.crc_id = Kit.generate_verhoeff_number(@kit)
    @kit.url_code = Kit.generate_url_code(@kit)

    respond_to do |format|
      if @kit.save
        # Remove this kit name from the unused kit names table
        if not UnusedKitName.find_by_name(@kit.name).nil? then
          UnusedKitName.find_by_name(@kit.name).destroy
        end
        # Log this
        KitLog.new(:actor => current_user, :comment => 'Kit created', :kit_id => @kit.id).save
        flash[:notice] = 'Kit was successfully created.'
        format.html { redirect_to(:controller => 'kits', :action => 'index') }
        format.xml  { render :xml => @kit, :status => :created, :location => @kit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kits/1
  # PUT /kits/1.xml
  def update
    @kit = Kit.find(params[:id])

    respond_to do |format|
      if @kit.update_attributes(params[:kit])
        flash[:notice] = 'Kit was successfully updated.'
        KitLog.new(:actor => current_user, :comment => 'Kit updated', :kit_id => @kit.id).save
        format.html { redirect_to(:controller => 'kits', :action => 'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kits/1
  # DELETE /kits/1.xml
  def destroy
    @kit = Kit.find(params[:id])
    if not @kit.last_mailed.nil? then
      flash[:error] = 'This kit can no longer be deleted, it is marked as sent'
      redirect_to(:controller => 'kits', :action => 'index')
      return
    end
    @kit.destroy

    respond_to do |format|
      format.html { redirect_to(request.referer || kits_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def load_selection
    super
    return unless @selection
    @selected_kits = Kit.where('id in (?)', @selection.target_ids)
    unless current_user.is_admin?
      @selected_kits = @selected_kits.where('originator_id = ?', current_user.id)
    end
  end

end
