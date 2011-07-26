class Admin::OauthServicesController < Admin::AdminControllerBase
  # GET /admin/oauth_services
  # GET /admin/oauth_services.xml
  def index
    @admin_oauth_services = OauthService.all
    @admin_oauth_services.each { |x| x[:privatekey_ok] = x.privatekey.nil? ? '-' : 'OK' }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_oauth_services }
    end
  end

  # GET /admin/oauth_services/1
  # GET /admin/oauth_services/1.xml
  def show
    @admin_oauth_service = OauthService.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_oauth_service }
    end
  end

  # GET /admin/oauth_services/new
  # GET /admin/oauth_services/new.xml
  def new
    @admin_oauth_service = OauthService.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_oauth_service }
    end
  end

  # GET /admin/oauth_services/1/edit
  def edit
    @admin_oauth_service = OauthService.find(params[:id])
  end

  # POST /admin/oauth_services
  # POST /admin/oauth_services.xml
  def create
    @admin_oauth_service = OauthService.new(params[:oauth_service])

    respond_to do |format|
      if @admin_oauth_service.save
        format.html { redirect_to([:admin, @admin_oauth_service], :notice => 'Oauth service was successfully created.') }
        format.xml  { render :xml => @admin_oauth_service, :status => :created, :location => @admin_oauth_service }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_oauth_service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/oauth_services/1
  # PUT /admin/oauth_services/1.xml
  def update
    @admin_oauth_service = OauthService.find(params[:id])

    respond_to do |format|
      if @admin_oauth_service.update_attributes(params[:oauth_service])
        format.html { redirect_to([:admin, @admin_oauth_service], :notice => 'Oauth service was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @admin_oauth_service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/oauth_services/1
  # DELETE /admin/oauth_services/1.xml
  def destroy
    @admin_oauth_service = OauthService.find(params[:id])
    raise "OAuth service is in use by tokens -- cannot destroy." if !@admin_oauth_service.oauth_tokens.empty?

    @admin_oauth_service.destroy

    respond_to do |format|
      format.html { redirect_to(admin_oauth_services_url) }
      format.xml  { head :ok }
    end
  end
end
