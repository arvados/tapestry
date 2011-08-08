class UsersController < ApplicationController
  skip_before_filter :ensure_enrolled

  before_filter :ensure_current_user_may_edit_this_user, :except => [ :initial, :create_initial, :new, :new_researcher, :new2, :create, :create_researcher, :activate, :created, :resend_signup_notification, :resend_signup_notification_form, :accept_enrollment, :tos, :accept_tos, :consent, :participant_survey, :show_log, :unauthorized, :shipping_address ]
  skip_before_filter :login_required, :only => [:initial, :create_initial, :new, :new_researcher, :new2, :create, :activate, :created, :create_researcher, :resend_signup_notification, :resend_signup_notification_form, :unauthorized ]
  skip_before_filter :ensure_tos_agreement, :only => [:tos, :accept_tos ]
  # We enforce signing of the TOS before we enforce the latest consent; make sure that people *can* sign the TOS even when their consent is out of date
  skip_before_filter :ensure_latest_consent, :only => [:tos, :accept_tos, :consent ]
  # Make sure people sign the latest TOS and Consent before they do safety questionnaires
  skip_before_filter :ensure_recent_safety_questionnaire, :only => [:tos, :accept_tos, :consent ]

  def initial
    @user = User.new(params[:user])
  end

  def create_initial
    if current_user or User.all.count != 0 then
      # Something fishy going on here
      redirect_to root_url
      return
    end
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.is_test = true
    success = @user && @user.save 
    errors = @user.errors

    if success && errors.empty?
      # We deliberately do not use @user.activate! here because that presumes an enrollment step, and the database is presumably entirely empty at this point.
      @user.activated_at = Time.now.utc
      @user.activation_code = nil
      @user.is_admin = true
      @user.save!
      @user.log('Initial admin account created and activated.')
      flash[:notice]  = "Your account was created."
      redirect_to root_url
    else
      # TODO FIXME
      puts errors
      flash[:error]  = "Please double-check your signup information below."
      redirect_to initial_user_url
    end
  end

  def new_researcher
    @user = User.new(params[:user])
  end

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
    # If no mailing lists are selected, we don't get the parameter back from the browser
    params[:user]['mailing_list_ids'] = [] if not params[:user].has_key?('mailing_list_ids')
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to root_url
    else
      @mailing_lists = MailingList.all
      render :action => 'edit'
    end
  end

  def create_researcher
    logout_keeping_session!
    @user = User.new(params[:user])

    # Just in case, force the 'researcher' flag to true
    @user.researcher = true

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
      flash.delete(:recaptcha_error)
      render :action => 'new_researcher'
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
#      flash[:error]  = "Please double-check your signup information below.<br/>&nbsp;"
      flash.delete(:recaptcha_error)
#      errors.each { |k,v|
#        # We only show e-mail and captcha errors; the rest is indicated next to the field.
#        if (k == 'base') then
#         flash[:error] += "<br/>#{CGI.escapeHTML(v)}"
#        elsif (k == 'email') then
#         flash[:error] += "<br/>#{k} #{CGI.escapeHTML(v)}"
#        end
#      }
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
    UserMailer.signup_notification(@user).deliver
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

  def participant_survey
     redirect_to google_survey_url(GoogleSurvey.find(1))
  end

  def show_log
    @log = UserLog.find(:all, :conditions => "user_id = #{current_user.id} and user_comment is not null", :order => 'created_at DESC')
    @log = @log.paginate(:page => params[:page] || 1, :per_page => 20)
  end

  # GET /users/shipping_address
  def shipping_address
    # If there is a shipping address for this user, show edit form, otherwise show new form
    if current_user.shipping_address.nil? then
      redirect_to(new_shipping_address_path)
    else
      redirect_to(edit_shipping_address_path(current_user.shipping_address.id))
    end
  end

  def edit_study
    @user = User.find(params[:id])
    @study = Study.where('id = ? and open = ?',params[:study_id],true).first
    if @study.nil? then
      # Only open studies should be available here
      redirect_to('/pages/studies')
      return
    end
    if not @user.study_participants.empty? and not @user.study_participants.where('study_id = ?',@study.id).empty? then
      @study_participant = @user.study_participants.where('study_id = ?',@study.id).first
    else
      @study_participant = nil
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @studies }
    end
  end

  def update_study
    @user = current_user
    @study = Study.find(params[:study_id])

    if @user.study_participants.empty? or @user.study_participants.where('study_id = ?',@study.id).empty? then
      @user.studies << @study
    end

    @sp = @user.study_participants.where('study_id = ?',@study.id).first
    @sp.status = StudyParticipant::STATUSES[params[:study_participant]['status']]

    if @sp.save
      flash[:notice] = 'Participation status updated.'
      redirect_to('/pages/studies')
    else
      format.html { render :action => "edit_study" }
    end
  end

  def withdraw
    @user = User.find(params[:id])
    @request_removal = params[:request_removal]
  end

  def withdraw_confirm
    @user = User.find(params[:id])
    if params[:user] and params[:user][:removal_requests]
      rr = RemovalRequest.new(:user => @user)
      rr.update_attributes(params[:user][:removal_requests])
      rr.save!
    end
    if @user.deactivated_at.nil?
      @user.log('Withdrew from the PGP.')
      @user.deactivated_at = Time.now
      @user.suspended_at = Time.now unless @user.suspended_at
      @user.can_unsuspend_self = false
      @user.save!
      UserMailer.withdrawal_notification(@user).deliver
      UserMailer.withdrawal_staff_notification(@user).deliver
    end
    redirect_to new_withdrawal_comment_path
  end

  private

  def ensure_current_user_may_edit_this_user
    redirect_to root_url unless current_user && ( current_user.id == params[:id].to_i ) && !current_user.deactivated_at # || current_user.admin?
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
