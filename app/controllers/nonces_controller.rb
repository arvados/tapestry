class NoncesController < ApplicationController

  def delete
    nonce = Nonce.find(params[:id])

    # For now, only supported for GoogleSurvey targets
    if not nonce.nil? and nonce.target_class == 'GoogleSurvey' and nonce.owner_class == 'User' then
      nonce.deleted = Time.now
      nonce.save!

      GoogleSurveyAnswer.where('nonce_id = ?',nonce.id).each do |gas|
        gas.destroy
      end

      current_user.log("Deleted google survey answers for nonce with id #{nonce.id} (#{nonce.nonce}) at participant's request")

      # Trigger a re-sync for the survey to purge the deleted lines from the csv file we serve
      ok, error_message = GoogleSurvey.find(nonce.target_id).synchronize!
      if ok
        flash[:notice] = "Deleted set of survey answers."
      else
        flash[:error] = error_message
      end
    
      respond_to do |format|
        format.html { redirect_to(google_survey_url(GoogleSurvey.find(nonce.target_id))) }
        format.xml  { head :ok }
      end
    else
      redirect_to unauthorized_user_url
    end
  end

end
