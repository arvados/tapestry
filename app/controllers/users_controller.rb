class UsersController < ApplicationController
  skip_before_filter :ensure_enrolled

  before_filter :ensure_current_user_may_edit_this_user, :except => [ :new, :new2, :create, :activate, :created, :resend_signup_notification, :resend_signup_notification_form, :accept_enrollment, :tos, :accept_tos, :consent, :show_log, :unauthorized ]
  skip_before_filter :login_required, :only => [:new, :new2, :create, :activate, :created, :resend_signup_notification, :resend_signup_notification_form, :unauthorized ]
  #before_filter :ensure_invited, :only => [:new, :new2, :create]
  skip_before_filter :ensure_tos_agreement, :only => [:tos, :accept_tos ]
  # We enforce signing of the TOS before we enforce the latest consent; make sure that people *can* sign the TOS even when their consent is out of date
  skip_before_filter :ensure_latest_consent, :only => [:tos, :accept_tos, :consent ]
  # Make sure people sign the latest TOS and Consent before they do safety questionnaires
  skip_before_filter :ensure_recent_safety_questionnaire, :only => [:tos, :accept_tos, :consent ]

  def new
    @user = User.new(params[:user])
  end

  def new2
    @user = User.new(params[:user])

    if params[:user] && @user.valid_for_attrs?(params[:user].keys)
      # Sometimes the error flash remains on the page, which is confusing. Kill it here if all is well.
      flash.delete(:error)

      @user.errors.clear
    else
      render :template => 'users/new'
    end
  end

  def edit
    @user = User.find params[:id]
    @mailing_lists = MailingList.all
  end

  def update
    @user = User.find params[:id]
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to root_url
    else
      @mailing_lists = MailingList.all
      render :action => 'edit'
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    if (params[:pgp_newsletter])
      if MailingList.find_by_name('PGP newsletter') then
        @user.mailing_lists = [ MailingList.find_by_name('PGP newsletter') ]
      end
    end

    success = @user && verify_recaptcha(@user) && @user.save
    errors = @user.errors

    if success && errors.empty?
      accept_invite!
      # Sometimes the error flash remains on the page, which is confusing. Kill it here if all is well.
      flash.delete(:error)
      # Same for recaptcha_error. Why does this happen?
      flash.delete(:recaptcha_error)
      flash.now[:notice] = "We have sent an e-mail to #{@user.email} in order to verify your e-mail address. To complete your registration please<br/>&nbsp;<br/>1. Check your e-mail for a message from the PGP<br/>2. Follow the link in the e-mail to complete your registration.<br/>&nbsp;<br/>If you do not see the message in your inbox, please check your bulk mail or spam folder for an e-mail from general@personalgenomes.org"
      redirect_to :action => 'created', :id => @user, :notice => "We have sent an e-mail to #{@user.email} in order to verify your e-mail address. To complete your registration please<br/>&nbsp;<br/>1. Check your e-mail for a message from the PGP<br/>2. Follow the link in the e-mail to complete your registration.<br/>&nbsp;<br/>If you do not see the message in your inbox, please check your bulk mail or spam folder for an e-mail from general@personalgenomes.org"
    else
      flash[:error]  = "Please double-check your signup information below.<br/>&nbsp;"
      errors.each { |k,v|
        # We only show e-mail and captcha errors; the rest is indicated next to the field.
        if (k == 'base') then
         flash[:error] += "<br/>#{CGI.escapeHTML(v)}"
        elsif (k == 'email') then
         flash[:error] += "<br/>#{k} #{CGI.escapeHTML(v)}"
        end
      }
      render :action => 'new2'
    end
  end

  def created
    @user = User.find_by_id(params[:id])
    flash.now[:notice] = params[:notice] if params[:notice]
    signup_enrollment_step = EnrollmentStep.find_by_keyword('signup')
    @user.log('Signed mini consent form version ' + LATEST_CONSENT_VERSION,signup_enrollment_step)
  end

  def destroy
    @user = User.find params[:id]
    UserMailer.deliver_delete_request(@user)
    logout_killing_session!
    flash[:notice] = "A request to delete your account has been sent."
    redirect_back_or_default page_url(:logged_out)
    
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:code]) unless params[:code].blank?
    case
    when (!params[:code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Your account is now activated. Please sign-in to continue."
      redirect_to '/login'
    when params[:code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def resend_signup_notification
    @user = nil
    if (params[:id]) then
      @user = User.find_by_id(params[:id])
    elsif (params[:user][:email]) then
      @user = User.find_by_email(params[:user][:email])
    end
    if not @user or @user.active? then
      # We deliberately return 'unknown user' when the user account is already active. No data leak here.
      flash.now[:error] = "Unknown user"
      render :template => 'users/resend_signup_notification_form'
      return
    end
    UserMailer.deliver_signup_notification(@user)
    flash.now[:notice] = "We have re-sent an e-mail to #{@user.email} in order to confirm your e-mail address. To complete your registration please<br/>&nbsp;<br/>1. Check your e-mail for a message from the PGP<br/>2. Follow the link in the e-mail to complete your registration.<br/>&nbsp;<br/>If you do not see the message in your inbox, please check your bulk mail or spam folder for an e-mail from general@personalgenomes.org"
    render :template => 'users/created'
  end

  def resend_signup_notification_form
  end

  def accept_enrollment
    if current_user.enrolled and not current_user.enrollment_accepted
      current_user.enrollment_accepted = Time.now()
      current_user.save!
      redirect_to root_url
    else
      # We should never get here.
      redirect_to root_url
    end
  end

  def consent
  end

  def tos
  end

  def unauthorized
  end

  def accept_tos
    if current_user.documents.kind('tos', 'v1').empty?
      current_user.documents << Document.new(:keyword => 'tos', :version => 'v1', :timestamp => Time.now())
      current_user.save!
      flash[:notice] = 'Thank you for agreeing with our Terms of Service.'
      redirect_to root_url
    else
      # They've already accepted this version of the terms of service
      redirect_to root_url
    end
  end

  def show_log
    @log = UserLog.find(:all, :conditions => "user_id = #{current_user.id} and user_comment is not null", :order => 'created_at DESC')
    @log = @log.paginate(:page => params[:page] || 1, :per_page => 20)
  end

  private

  def ensure_current_user_may_edit_this_user
    redirect_to root_url unless current_user && ( current_user.id == params[:id].to_i ) # || current_user.admin?
  end

  def ensure_invited
    unless session[:invited]
      flash[:error] = 'You must enter an invited email address to sign up.'
      redirect_to root_url
    end
  end

  def accept_invite!
    @invite = InvitedEmail.first(:conditions => { :email => session[:invited_email] })
    @invite.accept! if @invite
  end
end
