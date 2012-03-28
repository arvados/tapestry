class TraitwiseSurveysController < ApplicationController
  before_filter :ensure_researcher, :except => [:participate, :show, :index, :download]
  skip_before_filter :ensure_enrolled, :except => [:participate]

  def participate
    get_object
    if !@traitwise_survey.open
      flash[:error] = "This survey is not open for participation now."
      return redirect_to traitwise_survey_path(@traitwise_survey)
    end
    current_user.log("Clicked through to TraitwiseSurvey #{@traitwise_survey.id} (#{@traitwise_survey.name})", nil, request.remote_ip, "Clicked through to survey: #{@traitwise_survey.name}")
    redirect_to take_traitwise_survey_path(@traitwise_survey)
  end

  def decide_view_mode
    @can_edit = current_user.is_admin? or (@traitwise_survey and @traitwise_survey.user_id == current_user.id)
    @min_view = !@can_edit and !current_user.is_researcher?
    @can_download = (@traitwise_survey and
                     @sit.spreadsheet.last_downloaded_at and
                     (@traitwise_survey.is_result_public or
                      @traitwise_survey.user_id == current_user.id or
                      current_user.is_admin?))
  end

  def synchronize
    get_object
    decide_view_mode
    ok, error_message = @sit.synchronize!(current_user,request,cookies)
    if ok
      flash[:notice] = 'Results synchronized at ' + @sit.spreadsheet.last_downloaded_at.to_s
    else
      flash[:error] = error_message
    end
    redirect_to traitwise_survey_path(@traitwise_survey)
  end

  def download
    get_object
    decide_view_mode
    return access_denied unless @can_download

    filename = @traitwise_survey.name.gsub(' ','_').camelcase + '-' + @sit.spreadsheet.last_downloaded_at.strftime('%Y%m%d%H%M%S') + '.csv'

    @csv = CSV.generate_line(@sit.spreadsheet.header_row) + "\n"
    @sit.spreadsheet.spreadsheet_rows.each do |r|
      @csv += CSV.generate_line(r.row_data) + "\n"
    end

    send_data(@csv,
              :filename => filename,
              :disposition => 'attachment',
              :type => 'text/csv')
  end

  # GET /traitwise_surveys
  # GET /traitwise_surveys.xml
  def index
    decide_view_mode
    if @min_view
      @traitwise_surveys = TraitwiseSurvey.where(:is_listed => true)
    else
      @traitwise_surveys = TraitwiseSurvey.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @traitwise_surveys }
    end
  end

  # GET /traitwise_surveys/1
  # GET /traitwise_surveys/1.xml
  def show
    get_object
    decide_view_mode

    @nonces = Nonce.where(:owner_class => 'User', :owner_id => current_user.id,
                          :target_class => 'TraitwiseSurvey', :target_id => @traitwise_survey.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @traitwise_survey }
    end
  end

  # GET /traitwise_surveys/new
  # GET /traitwise_surveys/new.xml
  def new
    @traitwise_survey = TraitwiseSurvey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @traitwise_survey }
    end
  end

  # GET /traitwise_surveys/1/edit
  def edit
    get_object
  end

  # POST /traitwise_surveys
  # POST /traitwise_surveys.xml
  def create
    @traitwise_survey = TraitwiseSurvey.new(params[:traitwise_survey])
    @traitwise_survey.user_id = current_user.id

    respond_to do |format|
      if @traitwise_survey.save
        s = Spreadsheet.new(:name => "Auto-generated spreadsheet for Traitwise survey results")
        sit = SpreadsheetImporterTraitwise.new(:traitwise_survey => @traitwise_survey)
        sit.save
        s.spreadsheet_importer = sit
        s.save
        @traitwise_survey.spreadsheet = s
        @traitwise_survey.save
        format.html { redirect_to(@traitwise_survey, :notice => 'Traitwise survey was successfully created.') }
        format.xml  { render :xml => @traitwise_survey, :status => :created, :location => @traitwise_survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @traitwise_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /traitwise_surveys/1
  # PUT /traitwise_surveys/1.xml
  def update
    get_object

    respond_to do |format|
      if @traitwise_survey.update_attributes(params[:traitwise_survey])
        format.html { redirect_to(@traitwise_survey, :notice => 'Traitwise survey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @traitwise_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /traitwise_surveys/1
  # DELETE /traitwise_surveys/1.xml
  def destroy
    get_object
    @traitwise_survey.destroy

    respond_to do |format|
      format.html { redirect_to(traitwise_surveys_url) }
      format.xml  { head :ok }
    end
  end

private

  def get_object
    @traitwise_survey = TraitwiseSurvey.find(params[:id]) if params[:id] and !@traitwise_survey
    @sit = SpreadsheetImporterTraitwise.where('traitwise_survey_id = ?',@traitwise_survey.id).first
  end

end
