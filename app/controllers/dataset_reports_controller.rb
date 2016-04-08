class DatasetReportsController < ApplicationController
  skip_before_filter :login_required, :only => [:show]
  skip_before_filter :ensure_enrolled, :only => [:show]

  def show
    @report = DatasetReport.
      includes(:dataset, :user_file).
      where(:id => params[:id]).
      first
    if @report.nil?
      return not_found
    end

    @dataset = @report.dataset || @report.user_file

    unless @dataset.published_at or
        @dataset.published_anonymously_at or
        (current_user and
         (current_user.is_admin? or
          (@dataset.participant_id == current_user.id and
           @dataset.released_to_participant)))
      return not_found
    end

    if @report.display_url.nil?
      return not_found
    end

    redirect_to(@report.display_url)
  end
end
