class Admin::ReportsController < Admin::AdminControllerBase

  def index
    @reports = Report.all.sort { |a,b| b.requested <=> a.requested }.paginate(:page => params[:page] || 1)
  end

  def exam
    @passed_entrance_exam_count = User.has_completed('content_areas').count
    @content_areas = ContentArea.all
  end

  def queue
    @r = Report.new
    @r.user = current_user
    @r.name = params[:report_name]
    @r.rtype = params[:report_type]
    @r.requested = Time.now
    @r.status = "Queued for processing"
    @r.save!

    server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"
    begin
      out = server.create_report(current_user.id,@r.id,@r.name,@r.rtype)
      flash[:notice] = "Your report request has been queued for processing"
    rescue Exception => e
      error_message = "DRB server error when trying to create a report (#{@r.name} of type #{@r.rtype}): #{e.exception}"
      flash[:error] = "Unable to queue your report for processing: " + error_message
      current_user.log(error_message,nil,request.remote_ip)
      @r.status = error_message
      @r.save!
    end
    redirect_to admin_reports_url
  end

  def download
    @report = Report.find(params[:id])

    begin
      f = File.new(@report.path)
      data = f.read()
      f.close()
      filename = @report.path.gsub(/^.*\//,'')
    rescue Exception => e
      @report.user.log("Error downloading report: #{e.exception} #{e.inspect()}",nil,request.remote_ip)
      flash[:error] = "There was an error retrieving the report: #{e.exception}"
      redirect_to admin_reports_url
      return
    end

    respond_to do |format|
      format.html { send_data data, {
                     :filename    => filename,
                     :type        => 'application/' + @report.rtype,
                     :disposition => 'attachment' } }
    end
  end

end
