class UserFilesController < ApplicationController

  skip_before_filter :login_required, :only => [:download]
  skip_before_filter :ensure_enrolled, :only => [:download]

  # GET /user_file
  # GET /user_file.xml
  def index
    @user_files = current_user.user_files.find(:all).sort.paginate()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_file }
    end
  end

  # GET /user_file/new
  # GET /user_file/new.xml
  def new
    @user_file = UserFile.new
    @user_file.data_type = params[:data_type] if params[:data_type]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_file }
    end
  end

  # GET /user_file/1/edit
  def edit
    @user_file = UserFile.find(params[:id])

    @found = false
    UserFile::DATA_TYPES.each do |dt|
      if dt[1] == @user_file.data_type then
        @found = true
        break
      end
    end
    if not @found then
      @user_file.other_data_type = @user_file.data_type
      @user_file.data_type = 'other'
    end

  end

  # POST /user_file
  # POST /user_file.xml
  def create
    params[:user_file][:user_id] = current_user.id

    if params[:user_file][:data_type] == 'other' then
      params[:user_file][:data_type] = params[:user_file][:other_data_type]
    end

    @user_file = UserFile.new(params[:user_file])

#    if not params[:read_and_agreed] then
#      flash[:error] = 'You must agree to the terms and conditions for uploading data to your PGP participant profile.'
#      respond_to do |format|
#        format.html { render :action => "new" }
#      end
#      return
#    end

    respond_to do |format|
      if @user_file.save
        current_user.log("Uploaded new genetic dataset '#{@user_file.name}'")

        if @user_file.is_suitable_for_get_evidence? then
          server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"
          begin
            out = server.process_file(current_user.id,@user_file.id)
            flash[:notice] = "Dataset was successfully uploaded and has been queued for processing."
            current_user.log("Queued new genetic dataset '#{@user_file.name}' for processing")
          rescue Exception => e
            error_message = "DRB server error when trying to create a report for #{@user_file.class} ##{@user_file.id}: #{e.exception}"
            flash[:error] = "Dataset was successfully uploaded. There was an error queueing the dataset for processing."
            current_user.log(error_message,nil,request.remote_ip)
          end
        else
          flash[:notice] = 'Dataset was successfully uploaded.'
        end

        format.html { redirect_to(user_files_path) }
        format.xml  { render :xml => @user_file, :status => :created, :location => @user_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_file/1
  # PUT /user_file/1.xml
  def update
    @user_file = UserFile.find(params[:id])

    if params[:user_file][:data_type] == 'other' then
      params[:user_file][:data_type] = params[:user_file][:other_data_type]
    end

    respond_to do |format|
      if @user_file.update_attributes(params[:user_file])
        flash[:notice] = 'Dataset was updated successfully.'
        current_user.log("Updated genetic dataset '#{@user_file.name}'")
        format.html { redirect_to(user_files_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_file/1
  # DELETE /user_file/1.xml
  def destroy
    @user_file = UserFile.find(params[:id])
    current_user.log("Deleting genetic dataset '#{@user_file.name}'")

    begin
      @user_file.destroy
    rescue Exception => e
      current_user.log("Error deleting genetic data: #{e.exception} #{e.inspect()}",nil,request.remote_ip,"Error deleting dataset '#{@user_file.name}'.")
      flash[:error] = 'There was an error deleting the dataset. Please try again later.'
    end

    respond_to do |format|
      format.html { redirect_to(user_files_path) }
      format.xml  { head :ok }
    end
  end

  def download
    @user_file = UserFile.find(params[:id])

    begin
      f = File.new(@user_file.dataset.path)
      data = f.read()
      f.close()
      filename = @user_file.dataset.path.gsub(/^.*\//,'')
    rescue Exception => e
      @user_file.user.log("Error downloading genetic data: #{e.exception} #{e.inspect()}",nil,request.remote_ip,"Error retrieving dataset '#{@user_file.name}' for download.")
      flash[:error] = 'There was an error retrieving the dataset. Please try again later.'
      redirect_to user_file_url
      return
    end

    respond_to do |format|
      format.html { send_data data, {
                     :filename    => filename,
                     :type        => @user_file.dataset_content_type,
                     :disposition => 'attachment' } }
    end
  end

  def reprocess
    @user_file = UserFile.find(params[:id])
    if @user_file.is_suitable_for_get_evidence? then
      server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"
      begin
        out = server.process_file(current_user.id,@user_file.id)
        flash[:notice] = "Dataset has been queued for processing."
        current_user.log("Queued genetic dataset ##{@user_file.id} for processing")
      rescue Exception => e
        error_message = "DRB server error when trying to create a report for #{@user_file.class} ##{@user_file.id}: #{e.exception}"
        flash[:error] = "There was an error queueing the dataset for processing."
        current_user.log(error_message,nil,request.remote_ip)
      end
    end
    redirect_to(params[:return_to] || :back)
  end

end
