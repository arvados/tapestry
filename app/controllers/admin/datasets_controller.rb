class Admin::DatasetsController < Admin::AdminControllerBase
  
  before_filter :set_dataset, :only => [:edit, :update, :release, :notify, :reprocess]

  def index
    @datasets = Dataset.includes(:participant).all

    @users = Array.new()
    # Make a list of every participant that has taken each trait survey
    TRAIT_SURVEY_IDS.each do |ts_id|
      if @users.empty? then
        @users = Nonce.where("target_class=? and target_id = ? and used_at is not null",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      else
       @users = @users & Nonce.where("target_class=? and target_id = ? and used_at is not null",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      end
    end
  end

  def edit
  end

  def new
    @dataset = Dataset.new
  end


  def release
    @dataset.released_to_participant = true
    @dataset.save!
    @dataset.participant.log("Dataset '#{@dataset.name}' with id #{@dataset.id} was released to this participant")

    notify
  end

  def notify
    UserMailer.dataset_notification_message(specimen_analysis_data_index_url, @dataset.participant).deliver

    @dataset.sent_notification_at = Time.now()
    @dataset.save!

    @dataset.participant.log("Notified about release of dataset with id #{@dataset.id}")

    redirect_to admin_datasets_path
  end

  def create
    @dataset = Dataset.new(params[:dataset])

    if @dataset.save
      flash[:notice] = 'Dataset was successfully created.'
      maybe_submit_to_get_evidence
      redirect_to admin_datasets_path
    else
      render :action => 'new'
    end
  end

  def update
    if @dataset.update_attributes(params[:dataset])
      flash[:notice] = 'Dataset was successfully updated.'
      maybe_submit_to_get_evidence
      redirect_to admin_datasets_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @dataset = Dataset.find(params[:id])
    @dataset.destroy

    redirect_to(admin_datasets_url)
  end

  def reprocess
    submit!
    flash[:notice] = "Dataset ##{@dataset.id} re-submitted to GET-Evidence."
    redirect_to(params[:return_to] || :back)
  end

  private
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def maybe_submit_to_get_evidence
    return unless params[:dataset][:submit_to_get_e]
    submit!
  end

  def submit!
    begin
      @submitopts = {}
      @submitopts[:make_public] = !!@dataset.published_at
      if @dataset.published_anonymously_at and !@dataset.published_at
        @submitopts[:human_id] = ''
        @submitopts[:name] = ''
      end
      @dataset.submit_to_get_evidence!(@submitopts)
    rescue Exception => e
      # Callout error
      logger.debug "Error contacting GET-Evidence: #{e.inspect}"
      flash[:error] = "There was an error contacting GET-Evidence. Please try again later."
    end
  end

end
