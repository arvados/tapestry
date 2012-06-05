class Admin::DatasetsController < Admin::AdminControllerBase
  
  before_filter :set_dataset, :only => [:edit, :update, :notify]

  def index
    @datasets = Dataset.all
  end

  def edit
  end

  def new
    @dataset = Dataset.new
  end

  def notify
    @dataset.released_to_participant = true
    @dataset.save!

    @dataset.participant.log("Dataset '#{@dataset.name}' with id #{@dataset.id} was released to this participant")

    UserMailer.dataset_notification_message(root_url,@dataset.participant).deliver

    @dataset.sent_notification_at = Time.now()
    @dataset.save!

    @dataset.participant.log("Notified about release of dataset with id #{@dataset.id}")

    redirect_to admin_datasets_path
  end

  def create
    @dataset = Dataset.new(params[:dataset])

    if @dataset.save
      flash[:notice] = 'Dataset was successfully created.'
      redirect_to admin_datasets_path
    else
      render :action => 'new'
    end
  end

  def update
    if @dataset.update_attributes(params[:dataset])
      flash[:notice] = 'Dataset was successfully updated.'

      if params[:dataset][:submit_to_get_e] then
        # do GET-Evidence callback
        begin
          json_object = JSON.parse(open(URI.encode("#{GET_EVIDENCE_BASE_URL}/submit?api_key=#{GET_EVIDENCE_API_KEY}&api_secret=#{GET_EVIDENCE_API_SECRET}&dataset_locator=#{@dataset.locator}&dataset_name=#{@dataset.name}&dataset_is_public=false")).read)
          @dataset.location = json_object['result_url']
          @dataset.save!
        rescue Exception => e
          # Callout error
          STDERR.puts e.pretty_inspect()
          flash[:error] = "There was an error contacting GET-Evidence. Please try again later."
        end
      end
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

  private
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end
end
