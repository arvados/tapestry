class InternationalParticipantsController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :new, :create, :done]

  def index
    new
    render :action => 'new'
  end

  def new
    @international_participant = InternationalParticipant.new()
  end

  def create
    @international_participant = InternationalParticipant.new(params[:international_participant])
    if @international_participant.save
      flash.delete(:error)
      flash[:notice] = 'You have been added.'
      render :action => 'done'
    else
      flash.delete(:notice)
      flash[:error] = "Please double-check your e-mail address:<br/>&nbsp;"
      @international_participant.errors.each { |k,v|
        flash[:error] += "<br/>* #{CGI.escapeHTML(k)} #{CGI.escapeHTML(v)}"
      }
      render :action => 'new'
    end
  end

  def done
  end
end
