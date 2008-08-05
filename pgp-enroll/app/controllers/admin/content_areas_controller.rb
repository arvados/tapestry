class Admin::ContentAreasController < Admin::AdminControllerBase
  # GET /content_areas
  # GET /content_areas.xml
  def index
    @content_areas = ContentArea.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @content_areas }
    end
  end

  # GET /content_areas/1
  # GET /content_areas/1.xml
  def show
    @content_area = ContentArea.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content_area }
    end
  end

  # GET /content_areas/new
  # GET /content_areas/new.xml
  def new
    @content_area = ContentArea.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content_area }
    end
  end

  # GET /content_areas/1/edit
  def edit
    @content_area = ContentArea.find(params[:id])
  end

  # POST /content_areas
  # POST /content_areas.xml
  def create
    @content_area = ContentArea.new(params[:content_area])

    respond_to do |format|
      if @content_area.save
        flash[:notice] = 'ContentArea was successfully created.'
        format.html { redirect_to admin_content_areas_path }
        format.xml  { render :xml => @content_area, :status => :created, :location => admin_content_areas_path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /content_areas/1
  # PUT /content_areas/1.xml
  def update
    @content_area = ContentArea.find(params[:id])

    respond_to do |format|
      if @content_area.update_attributes(params[:content_area])
        flash[:notice] = 'ContentArea was successfully updated.'
        format.html { redirect_to([:admin, @content_area]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_area.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /content_areas/1
  # DELETE /content_areas/1.xml
  def destroy
    @content_area = ContentArea.find(params[:id])
    @content_area.destroy

    respond_to do |format|
      format.html { redirect_to(admin_content_areas_url) }
      format.xml  { head :ok }
    end
  end
end
