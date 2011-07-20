class GoogleSurveysController < ApplicationController
  before_filter :ensure_researcher, :except => [:participate]

  def participate
    @google_survey = GoogleSurvey.find(params[:id])
    qappend = ''
    if !@google_survey.userid_populate_entry.nil?
      @nonce = Nonce.new(:owner_class => 'User', :owner_id => current_user.id)
      qappend = '&entry_' + @google_survey.userid_populate_entry.to_s + '=' + @nonce.nonce
    end
    redirect_to @google_survey.form_url + qappend
  end

  def synchronize
    @google_survey = GoogleSurvey.find(params[:id])
    @google_survey.synchronize!
    flash[:notice] = 'Results synchronized at ' + @google_survey.last_downloaded_at.to_s
    redirect_to google_survey_path(@google_survey)
  end

  def download
    @google_survey = GoogleSurvey.find(params[:id])
    filename = @google_survey.name.gsub(' ','_').camelcase + '-' + @google_survey.last_downloaded_at.strftime('%Y%m%d%H%M%S') + '.csv'
    send_data(File.open(@google_survey.processed_csv_file, "rb").read,
              :filename => filename,
              :disposition => 'attachment',
              :type => 'text/csv')
  end

  # GET /google_surveys
  # GET /google_surveys.xml
  def index
    @google_surveys = GoogleSurvey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @google_surveys }
    end
  end

  # GET /google_surveys/1
  # GET /google_surveys/1.xml
  def show
    @google_survey = GoogleSurvey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @google_survey }
    end
  end

  # GET /google_surveys/new
  # GET /google_surveys/new.xml
  def new
    @google_survey = GoogleSurvey.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @google_survey }
    end
  end

  # GET /google_surveys/1/edit
  def edit
    @google_survey = GoogleSurvey.find(params[:id])
  end

  # POST /google_surveys
  # POST /google_surveys.xml
  def create
    @google_survey = GoogleSurvey.new(params[:google_survey])
    @google_survey.user_id = current_user.id

    respond_to do |format|
      if @google_survey.save
        format.html { redirect_to(@google_survey, :notice => 'Google survey was successfully created.') }
        format.xml  { render :xml => @google_survey, :status => :created, :location => @google_survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @google_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /google_surveys/1
  # PUT /google_surveys/1.xml
  def update
    @google_survey = GoogleSurvey.find(params[:id])

    respond_to do |format|
      if @google_survey.update_attributes(params[:google_survey])
        format.html { redirect_to(@google_survey, :notice => 'Google survey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @google_survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /google_surveys/1
  # DELETE /google_surveys/1.xml
  def destroy
    @google_survey = GoogleSurvey.find(params[:id])
    @google_survey.destroy

    respond_to do |format|
      format.html { redirect_to(google_surveys_url) }
      format.xml  { head :ok }
    end
  end
end
