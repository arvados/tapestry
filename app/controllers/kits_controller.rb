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
        redirect_to(:controller => 'studies', :action => 'claim')
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

    redirect_to(:controller => 'pages', :action => 'show', :id => 'studies' )
  end

  # POST /kit/1/returned
  def returned
    @kit = Kit.find(params[:id])

    if (@kit.participant != current_user) then
        flash[:error] = 'You do not have access to this kit'
        redirect_to(:controller => 'pages', :action => 'show', :id => 'studies')
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

    redirect_to(:controller => 'pages', :action => 'show', :id => 'studies')
  end

   # POST /kits/1/sent
  def sent
    @kit = Kit.find(params[:id])
    @kit.send_to_participant!(current_user)
    redirect_to(:controller => 'kits', :action => 'index')
  end
  
  # GET /kits
  # GET /kits.xml
  def index
    if current_user.is_admin? then
      @kits = Kit.all
    else
      @kits = Kit.where('originator_id = ?',current_user.id)
    end
    @kits = @kits.paginate(:page => params[:page] || 1, :per_page => 30)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kits }
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
      format.html { redirect_to(kits_url) }
      format.xml  { head :ok }
    end
  end

end
