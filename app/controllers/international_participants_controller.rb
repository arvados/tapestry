class InternationalParticipantsController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled

  def index
    new
    render :action => 'new'
  end

  def new
    @international_participant = InternationalParticipant.new()
  end

  def create
    @international_participant = InternationalParticipant.new(params[:international_participant])
    # We prefer to store the full country name in the table
    @international_participant.country = Carmen::country_name(params[:international_participant]['country'])
    if @international_participant.save
      flash.delete(:error)
      flash[:notice] = 'You have been added.'
      render :action => 'done'
    else
      render :action => 'new'
    end
  end

  def done
  end
end
