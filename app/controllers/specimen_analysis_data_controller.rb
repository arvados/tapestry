class SpecimenAnalysisDataController < ApplicationController
  
  before_filter :set_dataset, :only => [:publish]
  before_filter :only_participant_can_operate, :only => [:publish]

  skip_before_filter :ensure_dataset_release

  skip_before_filter :ensure_dataset_release

  def index
    @datasets = current_user.datasets.where('released_to_participant')
    # Mark datasets as seen by participant, but *only* if it is really them, and not
    # a cloaked admin, who is viewing this page.
    if not session[:real_uid] or not session[:switch_back_to] then
      @datasets.each do |ds|
        if ds.seen_by_participant_at.nil?
          ds.seen_by_participant_at = Time.now()
          ds.save
          current_user.log("Participant saw dataset #{ds.name} (#{ds.id})")
        end
      end
    else
      flash[:warning] = 'You a cloaked administrator; viewing this page does not set the "seen_by_participant_at" flag on the datasets listed'
    end
    @trait_surveys = GoogleSurvey.
      where('id in (?)', TRAIT_SURVEY_IDS).
      order(:id)
    @trait_surveys_completed = Nonce.
      where('owner_class=? and owner_id=? and target_class=? and target_id in (?) and used_at is not ?',
            'User', current_user.id,
            'GoogleSurvey', TRAIT_SURVEY_IDS,
            nil).
      collect(&:target_id)
  end

  def publish
    if params[:anonymous] then
      @dataset.published_anonymously_at = Time.now()
      @dataset.save
      # Just in case, remove the hu_id and name reference from the dataset on the GET-E report
      # We don't link to the report, but its url can easily be guessed based on other public GET-E reports
      @dataset.submit_to_get_evidence!(:name => '', :human_id => '')
      flash[:notice] = 'Your dataset has been published anonymously. Please make sure to take all the trait surveys. Thank you!'
      current_user.log("Participant published dataset #{@dataset.name} (#{@dataset.id}) anonymously")
    elsif make_public_on_get_evidence then
      @dataset.published_at = Time.now()
      @dataset.save
      flash[:notice] = 'Your dataset has been published. Thank you!'
      current_user.log("Participant published dataset #{@dataset.name} (#{@dataset.id})")
    else
      flash[:error] = 'There was an error publishing your dataset. The site administrators have been notified, and we will fix this problem as soon as possible. Please come back in a little bit to try again.'
      current_user.log("Participant tried to publish dataset #{@dataset.name} (#{@dataset.id}) but the call to GET-Evidence failed. Dataset not made public yet, user informed of error and asked to come back later to try again.")
    end 
    redirect_to specimen_analysis_data_index_url
  end

private
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def only_participant_can_operate
    return access_denied unless @dataset.participant_id == current_user.id or current_user.is_admin?
  end

  def make_public_on_get_evidence
    begin
      @dataset.submit_to_get_evidence!(:make_public => true)
      return true
    rescue Exception => e
      # Callout error
      STDERR.puts "Error contacting GET-Evidence: #{e.inspect}"
      # TODO FIXME: this needs to throw an admin error
      return false
    end
  end

end
