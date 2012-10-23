class NoncesController < ApplicationController

  def delete
    nonce = Nonce.find(params[:id])

    # For now, only supported for GoogleSurvey targets
    if not nonce.nil? and nonce.target_class == 'GoogleSurvey' and nonce.owner_class == 'User' then
      nonce.deleted = Time.now
      nonce.save!
      current_user.log("Marked google survey answers for nonce with id #{nonce.id} (#{nonce.nonce}) as deleted")
    
      respond_to do |format|
        format.html { redirect_to(google_survey_url(GoogleSurvey.find(nonce.target_id))) }
        format.xml  { head :ok }
      end
    else
      redirect_to unauthorized_user_url
    end
  end

end
