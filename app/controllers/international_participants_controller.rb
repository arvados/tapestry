class InternationalParticipantsController < ApplicationController
  def new
    @international_participant = InternationalParticipant.new()
  end

  def create
    @international_participant = InternationalParticipant.new(params[:international_participant])
    if @international_participant.save
       flash[:notice] = 'You have been added.'
       render :action => 'done'
    end
  end

  def done
  end
end
