class AcceptedInvitesController < ApplicationController
  skip_before_filter :login_required, :only => [:create]

  def create
    @invite = InvitedEmail.first(:conditions => { :email => params[:email] })

    if valid_invite?
      accept_invite
      redirect_to page_url(:introduction)
    elsif used_invite?
      deny_invite("Sorry, that email address has already been used to enroll.")
      redirect_to page_url(:home)
    else
      deny_invite("Sorry, that email address and invite code have not yet been invited.")
      redirect_to page_url(:home)
    end
  end

  private

  def used_invite?
    @invite && @invite.accepted_at
  end

  def valid_invite?
    !used_invite? && @invite && params[:code] == InvitedEmail::INVITE_CODE
  end

  def deny_invite(error_message)
    session[:invited] = false
    session[:invited_email] = nil
    flash[:error] = error_message
  end

  def accept_invite
    session[:invited] = true
    session[:invited_email] = params[:email]
  end

end
