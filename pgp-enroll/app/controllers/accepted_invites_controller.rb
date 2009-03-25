class AcceptedInvitesController < ApplicationController
  skip_before_filter :login_required, :only => [:create]

  def create
    invite = InvitedEmail.first(:conditions => { :email => params[:email] })

    if invite
      invite.accept!
      session[:invited] = true
      redirect_to page_url(:introduction)
    else
      session[:invited] = false
      flash[:error] = "Sorry, that email address has not yet been invited to enroll."
      redirect_to page_url(:home)
    end
  end
end
