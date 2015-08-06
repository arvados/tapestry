class GoogleSurveysController < ApplicationController
  before_filter {|c| c.check_section_disabled(Section::GOOGLE_SURVEYS) }
  before_filter :ensure_researcher, :except => [:participate, :show, :index, :download]
  skip_before_filter :ensure_enrolled, :except => [:participate]
  skip_before_filter :login_required, :only => [:show, :index, :download]
  skip_before_filter :ensure_active, :only => [:show, :index, :download]
  before_filter :get_object, :only => [ :synchronize, :download, :show, :edit, :update, :destroy ]
  before_filter :decide_view_mode, :only => [ :synchronize, :download, :index, :show ]
  before_filter :check_section_disabled_special, :only => [:show, :index, :download]

  # Need a special method for the semi-complicated permissions of this controller.
  # Basically if the PUBLIC_DATA section is *not* enabled then only certain surveys can be seen.
  # NB: That the entire google surveys section of Tapestry can be deactivated at once (see the earlier before_filter)
  def check_section_disabled_special
    @min_view = true unless include_section?(Section::PUBLIC_DATA)
  end

  def participate
    @google_survey = GoogleSurvey.find(params[:id])
    if !@google_survey.open
      flash[:error] = "This survey is not open for participation now."
      return redirect_to google_survey_path(@google_survey)
    end
    url = @google_survey.form_url
    url += '?' unless url.include? '?'
    if !@google_survey.userid_populate_entry.nil?
      @nonce = Nonce.new(:owner_class => 'User', :owner_id => current_user.id,
                         :target_class => 'GoogleSurvey', :target_id => @google_survey.id)
      url += '&entry.' + @google_survey.userid_populate_entry.to_s + '=' + @nonce.nonce
    end
    current_user.log("Clicked through to GoogleSurvey #{@google_survey.id} (#{@google_survey.name}) with nonce #{@nonce.nonce}", nil, request.remote_ip, "Clicked through to survey: #{@google_survey.name}")
    redirect_to url
  end

  def get_object
    @google_survey = GoogleSurvey.find(params[:id]) if params[:id] and !@google_survey
  end

  def decide_view_mode
    @can_edit = current_user && (current_user.is_admin? || (@google_survey && @google_survey.user_id == current_user.id))
    @min_view = !@can_edit && !(current_user && current_user.is_researcher?)
    @can_download = (@google_survey and
                     @google_survey.last_downloaded_at and
                     (@google_survey.is_result_public or
                      (current_user and
                       (@google_survey.user_id == current_user.id or
                        current_user.is_admin?))))
  end

  def synchronize
    ok, error_message = @google_survey.synchronize!
    if ok
      flash[:notice] = 'Results synchronized at ' + @google_survey.last_downloaded_at.to_s
    else
      flash[:error] = error_message
    end
    redirect_to google_survey_path(@google_survey)
  end

  def download
    return access_denied unless @can_download
    filename = @google_survey.name.gsub(' ','_').camelcase + '-' + @google_survey.last_downloaded_at.strftime('%Y%m%d%H%M%S') + '.csv'
    send_data(File.open(@google_survey.processed_csv_file, "rb").read,
              :filename => filename,
              :disposition => 'attachment',
              :type => 'text/csv')
  end

  # GET /google_surveys
  # GET /google_surveys.xml
  def index
    if @min_view
      @google_surveys = GoogleSurvey.where(:is_listed => true)
    else
      @google_surveys = GoogleSurvey.all
    end

    @my_google_survey_responses = current_user.nil? ? [] : Nonce.
      where(:owner_class => 'User',
            :owner_id => current_user.id,
            :target_class => 'GoogleSurvey').
      select(&:used_at)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @google_surveys }
    end
  end

  # GET /google_surveys/1
  # GET /google_surveys/1.xml
  def show
    @nonces = Nonce.where(:owner_class => 'User', :owner_id => current_user.id,
                          :target_class => 'GoogleSurvey', :target_id => @google_survey.id) if current_user

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
    @google_survey.destroy

    respond_to do |format|
      format.html { redirect_to(google_surveys_url) }
      format.xml  { head :ok }
    end
  end
end
