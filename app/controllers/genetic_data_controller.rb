class GeneticDataController < ApplicationController

  skip_before_filter :login_required, :only => [:download]
  skip_before_filter :ensure_enrolled, :only => [:download]

  # GET /genetic_data
  # GET /genetic_data.xml
  def index
    @genetic_data = current_user.genetic_data.find(:all).sort.paginate()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @genetic_data }
    end
  end

  # GET /genetic_data/1
  # GET /genetic_data/1.xml
  def show
    @genetic_data = GeneticData.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @genetic_data }
    end
  end

  # GET /genetic_data/new
  # GET /genetic_data/new.xml
  def new
    @genetic_data = GeneticData.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @genetic_data }
    end
  end

  # GET /genetic_data/1/edit
  def edit
    @genetic_data = GeneticData.find(params[:id])
  end

  # POST /genetic_data
  # POST /genetic_data.xml
  def create
    params[:genetic_data][:user_id] = current_user.id
    @genetic_data = GeneticData.new(params[:genetic_data])
    if not params[:read_and_agreed] then
      flash[:error] = 'You must agree to the terms and conditions for uploading data to your PGP participant profile.'
      respond_to do |format|
        format.html { render :action => "new" }
      end
      return
    end

    respond_to do |format|
      if @genetic_data.save
        flash[:notice] = 'Dataset was successfully uploaded.'
        current_user.log("Uploaded new genetic dataset '#{@genetic_data.name}'")
        format.html { redirect_to(genetic_data_path) }
        format.xml  { render :xml => @genetic_data, :status => :created, :location => @genetic_data }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @genetic_data.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /genetic_data/1
  # PUT /genetic_data/1.xml
  def update
    @genetic_data = GeneticData.find(params[:id])

    respond_to do |format|
      if @genetic_data.update_attributes(params[:genetic_data])
        flash[:notice] = 'Dataset was updated successfully.'
        current_user.log("Updated genetic dataset '#{@genetic_data.name}'")
        format.html { redirect_to(genetic_data_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @genetic_data.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /genetic_data/1
  # DELETE /genetic_data/1.xml
  def destroy
    @genetic_data = GeneticData.find(params[:id])
    current_user.log("Deleting genetic dataset '#{@genetic_data.name}'")

    begin
      @genetic_data.destroy
    rescue Exception => e
      current_user.log("Error deleting genetic data: #{e.exception} #{e.inspect()}",nil,nil,"Error deleting dataset '#{@genetic_data.name}'.")
      flash[:error] = 'There was an error deleting the dataset. Please try again later.'
    end

    respond_to do |format|
      format.html { redirect_to(genetic_data_url) }
      format.xml  { head :ok }
    end
  end

  def download
    @genetic_data = GeneticData.find(params[:id])

    begin
      f = File.new(@genetic_data.dataset.path)
      data = f.read()
      f.close()
      filename = @genetic_data.dataset.path.gsub(/^.*\//,'')
    rescue Exception => e
      @genetic_data.user.log("Error downloading genetic data: #{e.exception} #{e.inspect()}",nil,nil,"Error retrieving dataset '#{@genetic_data.name}' for download.")
      flash[:error] = 'There was an error retrieving the dataset. Please try again later.'
      redirect_to genetic_data_url
      return
    end

    respond_to do |format|
      format.html { send_data data, {
                     :filename    => filename,
                     :type        => @genetic_data.dataset_content_type,
                     :disposition => 'attachment' } }
    end
  end
end
