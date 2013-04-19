class DatasetsController < ApplicationController
  skip_before_filter :login_required, :only => [:download, :show]
  skip_before_filter :ensure_enrolled, :only => [:download, :show]

  def download
    @dataset = Dataset.find(params[:id])
    if @dataset.published_at or
        @dataset.published_anonymously_at or
        (current_user and
         (current_user.is_admin? or
          (@dataset.participant_id == current_user.id and
           @dataset.released_to_participant)))
      x = @dataset.download_url
      return redirect_to(x) if x
      flash[:error] = "Sorry, this file is temporarily unavailable."
      return redirect_to :back
    end
    flash[:error] = "The file you requested does not seem to exist."
    return redirect_to public_genetic_data_path
  end
end
