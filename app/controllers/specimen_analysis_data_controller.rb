class SpecimenAnalysisDataController < ApplicationController
  
  before_filter :set_dataset, :only => [:publish]

  def index
    @datasets = current_user.datasets.all
    @datasets.each do |ds|
      if ds.seen_by_participant_at.nil?
        ds.seen_by_participant_at = Time.now() 
        ds.save
        current_user.log("Participant saw dataset #{ds.name} (#{ds.id})")
      end
    end
  end

  def publish
    if make_public_on_get_evidence then
      @dataset.published_at = Time.now()
      @dataset.save
      flash[:notice] = 'Your dataset has been published. Thank you!'
      current_user.log("Participant published dataset #{@dataset.name} (#{@dataset.id})")
    else
      flash[:error] = 'There was an error making your dataset public. The site administrators have been notified, and we will fix this problem as soon as possible. Please come back in a little bit to try again.'
      current_user.log("Participant tried to publish dataset #{@dataset.name} (#{@dataset.id}) but the call to GET-Evidence failed. Dataset not made public yet, user informed of error and asked to come back later to try again.")
    end 
    redirect_to specimen_analysis_data_url
  end

private
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def make_public_on_get_evidence
    begin
      @dataset.submit_to_get_evidence!(1)
      return true
    rescue Exception => e
      # Callout error
      STDERR.puts "Error contacting GET-Evidence: #{e.inspect}"
      # TODO FIXME: this needs to throw an admin error
      return false
    end
  end

end
