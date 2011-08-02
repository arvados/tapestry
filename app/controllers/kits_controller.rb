class KitsController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  before_filter :ensure_researcher, :except => ['claim']

  # TMP TO DEAL WITH DUPLICATE KIT NAME
  def claim_danforth
    @kit = Kit.where('last_mailed is not ? and name = ?',nil,params[:name]).first

    if request.post? then
      if params.has_key?('danforth_or_adair') and params[:danforth_or_adair] == '37764001' then
        flash[:notice] = 'Thank you, you have the real kit named <strong>Danforth</strong>. We now know which kit you have, please proceed with the confirmation process below.'
        redirect_to(:controller => 'kits', :action => 'claim', :name => 'Danforth', :for_real => '1')
        return
      elsif params.has_key?('danforth_or_adair') and params[:danforth_or_adair] == '79615591' then
        flash[:notice] = 'Thank you, the real name for your kit is <strong>Adair</strong>. If you wish, you may relabel the sample tubes as <strong>Adair</strong>, but you do not need to. We now know which kit you have, so please proceed with the confirmation process below.'
        redirect_to(:controller => 'kits', :action => 'claim', :name => 'Adair')
        return
      else
        flash[:notice] = 'Please select a kit id number'
        redirect_to(:controller => 'kits', :action => 'claim_danforth', :name => 'Danforth')
        return
      end
    end

  end

  # GET /kit/claim
  def claim
    @kit = Kit.where('last_mailed is not ? and name = ?',nil,params[:name]).first
    if (@kit.nil?) then
        flash[:error] = 'We do not have a record of a kit with this name. Please double check the spelling. If you are certain the spelling is correct, please contact support@personalgenomes.org.'
        redirect_to(:controller => 'studies', :action => 'claim')
        return
    end
    # TMP TO DEAL WITH DUPLICATE KIT NAME
    if (@kit.name == 'Danforth' and not params.has_key?('for_real')) then
        redirect_to(:controller => 'kits', :action => 'claim_danforth', :name => params[:name])
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
      SampleLog.new(:actor_id => @current_user.id, :comment => 'Sample received by participant', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor_id => @current_user.id, :comment => 'Kit received by participant', :kit_id => @kit.id).save
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
      SampleLog.new(:actor_id => @current_user.id, :comment => 'Sample returned to researcher', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor_id => @current_user.id, :comment => 'Kit returned to researcher', :kit_id => @kit.id).save
    current_user.log("Kit #{@kit.name} (#{@kit.id}) returned to researcher",nil,request.remote_ip,"Kit #{@kit.name} returned to researcher")

    redirect_to(:controller => 'pages', :action => 'show', :id => 'studies')
  end

   # POST /kit/1/sent
  def sent
    @kit = Kit.find(params[:id])

    @kit.last_mailed = Time.now()
    @kit.shipper_id = current_user.id
    # Nobody 'owns' the kit at the moment
    @kit.owner = nil
    @kit.save

    @kit.samples.each do |s|
      s.last_mailed = Time.now()
      s.owner = nil
      s.save
      SampleLog.new(:actor_id => @current_user.id, :comment => 'Sample sent', :sample_id => s.id).save
    end

    # Log this
    KitLog.new(:actor_id => @current_user.id, :comment => 'Kit sent', :kit_id => @kit.id).save

    redirect_to(:controller => 'kits', :action => 'index')
  end
  
  # GET /kits
  # GET /kits.xml
  def index
    @kits = Kit.where('originator_id = ?',current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kits }
    end
  end

  # GET /kits/1/log
  def show_log
    @kit = Kit.find(params[:id])
    @kit_log = KitLog.where('kit_id = ?', @kit.id).sort { |a,b| b.updated_at <=> a.updated_at }
  end

  # GET /kits/1
  # GET /kits/1.xml
  def show
    @kit = Kit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @kit }
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

  # POST /kits
  # POST /kits.xml
  def create
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
        KitLog.new(:actor_id => @current_user.id, :comment => 'Kit created', :kit_id => @kit.id).save
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
        KitLog.new(:actor_id => @current_user.id, :comment => 'Kit updated', :kit_id => @kit.id).save
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
