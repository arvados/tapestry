class UserFilesController < ApplicationController

  load_and_authorize_resource :except => [:download, :show]

  skip_before_filter :login_required, :only => [:download, :show]
  skip_before_filter :ensure_enrolled, :only => [:download, :show]

  include Longupload::Receiver

  # GET /user_file
  # GET /user_file.xml
  def index
    @user_files = (current_user.user_files.find(:all) | current_user.incomplete_user_files.find(:all)).sort.paginate()

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
    @user_file.using_plain_upload = params[:user_file][:using_plain_upload] if params[:user_file]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_file }
    end
  end


  # GET /user_file/1/edit
  def edit
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
    # Maybe the user asked for the plain uploader (or File API is not present)
    @user_file.using_plain_upload = params[:user_file][:using_plain_upload] rescue false
    # Maybe there's no point using the fancy uploader because there is
    # no uploading left to do
    @user_file.using_plain_upload ||= !@user_file.is_incomplete?
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
        if !(@user_file.dataset and @user_file.dataset_file_name)
          # wait for the longupload before proclaiming success
        else
          finished_uploading_file
        end

        format.html { redirect_to(user_files_path) }
        format.xml  { render :xml => @user_file, :status => :created, :location => @user_file }
        format.json { render :json => extended_api_response }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_file.errors, :status => :unprocessable_entity }
        format.json  { render :json => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  def longupload
    was_incomplete = @user_file.is_incomplete?
    r = super :target => @user_file
    if @response['complete'] and was_incomplete
      finished_uploading_file
    end
    r
  end

  def finished_uploading_file
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
  end

  # PUT /user_file/1
  # PUT /user_file/1.xml
  def update
    if params[:user_file][:data_type] == 'other' then
      params[:user_file][:data_type] = params[:user_file][:other_data_type]
    end

    respond_to do |format|
      if @user_file.update_attributes(params[:user_file])
        flash[:notice] = 'Dataset was updated successfully.'
        current_user.log("Updated genetic dataset '#{@user_file.name}'")
        format.html { redirect_to(user_files_path) }
        format.xml  { head :ok }
        format.json { render :json => extended_api_response }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_file.errors, :status => :unprocessable_entity }
        format.json { render :json => @user_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_file/1
  # DELETE /user_file/1.xml
  def destroy
    @user_file = UserFile.find(params[:id])
    current_user.log("Removing user file ##{@user_file.id} '#{@user_file.name}'")

    begin
      @user_file.destroy
      flash[:notice] = 'The file has been removed.'
    rescue Exception => e
      current_user.log("Error removing user file: #{e.exception} #{e.inspect()}",nil,request.remote_ip,"Error removing user file ##{@user_file.id} '#{@user_file.name}'.")
      flash[:error] = 'There was an error removing the file. Please try again later.'
    end

    respond_to do |format|
      format.html { redirect_to(user_files_path) }
      format.xml  { head :ok }
    end
  end

  def show
    @user_file = UserFile.find(params[:id])
    if (@user_file.is_incomplete? or
        ((@user_file.user.suspended_at or !@user_file.user.is_enrolled?) and
         !(current_user and (current_user.is_admin? or current_user.id == @user_file.user.id))))
      redirect_to unauthorized_user_url
    end
  end

  def download
    @user_file = UserFile.find(params[:id])

    filename = @user_file.user.hex + '_' + @user_file.created_at.strftime('%Y%m%d%H%M%S') + '.' + (@user_file.dataset.path || @user_file.longupload_file_name).sub(/^.*\./,'')

    if @user_file.data_size > 2**20 and !File.exists? @user_file.dataset.path
      # Here we assume there is only one file in the manifest, and
      # it's not in a subdir.  Longupload currently ensures that, but
      # we should be able to detect multi-file manifests and respond
      # with a tarball instead of failing.
      if defined? WAREHOUSE_WEB_ROOT and
          defined? WAREHOUSE_FS_ROOT and
          (filelist = Dir.glob("#{WAREHOUSE_FS_ROOT}/#{@user_file.locator}/*")) and
          filelist.size == 1
        return redirect_to filelist[0].sub(WAREHOUSE_FS_ROOT, WAREHOUSE_WEB_ROOT)
      elsif defined? WAREHOUSE_PROXY_SCRIPT_PATH
        return redirect_to(WAREHOUSE_PROXY_SCRIPT_PATH +
                           '?locator=' + Rack::Utils.escape(@user_file.locator + '/') +
                         '&filename=' + Rack::Utils.escape(filename) +
                         '&size=' + @user_file.data_size.to_s +
                         '&type=' + Rack::Utils.escape(@user_file.dataset_content_type) +
                         '&disposition=attachment')
      else
        flash[:error] = "Sorry, downloading large files is not yet supported."
        return redirect_to url_for(@user_file)
      end
    end

    begin
      io = @user_file.data_stream
    rescue Exception => e
      @user_file.user.log("Error downloading user file: #{e.exception} #{e.inspect()}",nil,request.remote_ip,"Error retrieving dataset ##{@user_file.id} '#{@user_file.name}' for download.")
      flash[:error] = 'There was an error retrieving the dataset. Please try again later.'
      redirect_to url_for(@user_file)
      return
    end

    respond_to do |format|
      format.any {
        send_data io.read, {
          :filename => filename,
          :type => @user_file.dataset_content_type,
          :disposition => 'attachment'
        }
      }
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

  protected
  def longupload_target_class
    UserFile
  end

  def extended_api_response
    @user_file.
      as_api_response(:owner).
      merge(
            :item_path => edit_user_file_path(@user_file),
            :item_update_path => user_file_path(@user_file),
            :upload_handler => longupload_user_file_path(@user_file)
            )
  end
end
