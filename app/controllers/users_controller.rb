class UsersController < ApplicationController
  skip_before_filter :ensure_enrolled

  before_filter :ensure_current_user_may_edit_this_user, :except => [ :initial, :create_initial, :new, :new_researcher, :new2, :create, :create_researcher, :activate, :created, :resend_signup_notification, :resend_signup_notification_form, :accept_enrollment, :tos, :accept_tos, :consent, :participant_survey, :show_log, :unauthorized, :shipping_address, :switch_to, :index ]
  skip_before_filter :login_required, :only => [:initial, :create_initial, :new, :new_researcher, :new2, :create, :activate, :created, :create_researcher, :resend_signup_notification, :resend_signup_notification_form, :unauthorized, :index ]
  skip_before_filter :ensure_tos_agreement, :only => [:tos, :accept_tos, :switch_to, :index ]
  # We enforce signing of the TOS before we enforce the latest consent; make sure that people *can* sign the TOS even when their consent is out of date
  skip_before_filter :ensure_latest_consent, :only => [:tos, :accept_tos, :consent, :switch_to, :index ]
  # Make sure people sign the latest TOS and Consent before they do safety questionnaires
  skip_before_filter :ensure_recent_safety_questionnaire, :only => [:tos, :accept_tos, :consent, :switch_to, :index ]

  def index
    @page_title = 'Participant profiles'
    page = (1 + params[:iDisplayStart].to_i / params[:iDisplayLength].to_i).to_i rescue nil
    page ||= params[:page].to_i
    page ||= 1
    page = 1 unless page > 0
    per_page = [(params[:iDisplayLength] || 10).to_i, 100].min

    must_do_custom_sort = false
    sortcol_max = [params[:iSortingCols].to_i - 1, 5].min
    sql_orders = []
    joins = {}
    (0..sortcol_max).each do |sortcol_index|
      # sortcol_index='0' === the first key we're sorting on

      # sortcol === the column we're sorting on (0-based)
      sortcol = params["iSortCol_#{sortcol_index}".to_sym]
      next if !sortcol

      # sortkey === the hash key (property name) of the data we're sorting on
      sortkey = params["mDataProp_#{sortcol}".to_sym]
      next if !sortkey

      # sql_column === the sql expression we're sorting on
      sql_column = case sortkey.to_sym
                   when :hex, :enrolled
                     sortkey
                   when :received_sample_materials
                     joins[:samples] = {}
                     'count(samples.id)>0'
                   when :ccrs
                     joins[:ccrs] = {}
                     'count(ccrs.id)>0'
                   when :has_relatives_enrolled
                     joins[:family_relations] = {}
                     'count(family_relations.id)'
                   when :has_whole_genome_data
                     joins[:datasets] = {}
                     'count(datasets.id)'
                   when :has_other_genetic_data
                     joins[:genetic_data] = {}
                     'count(genetic_data.id)'
                   else
                     must_do_custom_sort = true
                     'hex'
                   end
      sql_direction = params["sSortDir_#{sortcol_index}".to_sym] == 'desc' ? 'desc' : 'asc'
      sql_orders.push "#{sql_column} #{sql_direction}"
    end
    sql_order = sql_orders.empty? ? 'enrolled asc' : sql_orders.join(',')
    sql_search = '1'
    if params[:sSearch] and params[:sSearch].length > 0
      sql_search = "hex LIKE :search"
      if current_user and (current_user.is_admin? or
                           current_user.is_researcher_onirb?)
        sql_search << " OR concat(first_name,' ',if(middle_name='','',concat(middle_name,' ')),last_name) LIKE :search"
      end
    end
    @total = User.enrolled.publishable
    if false and must_do_custom_sort
      # The following code gets horrendously slow when it invokes SQL
      # queries in the sort function -- so slow it's surely better to
      # not let the user search by a column if it can't be done by the
      # database.  Hence "if false and..."
      @filtered = @total.find(:all, :conditions => [ sql_search, { :search => "%#{params[:sSearch]}%" } ])
      @filtered = @filtered.collect { |u| u.as_json(:for => current_user) }
      @filtered.sort! { |a,b|
        cmp = 0
        (0..sortcol_max).each do |sortcol|
          sortkey = params['mDataProp_'+params["iSortCol_#{sortcol}"]].to_sym
          cmp = case sortkey
                when :hex, :enrolled
                  a[sortkey] <=> b[sortkey]
                when :ccrs
                  # ...
                else
                  a[:hex] <=> b[:hex]
                end
          cmp = cmp * (params["sSortDir_#{sortcol}".to_sym] == 'desc' ? -1 : 1)
          break unless cmp == 0
        end
        cmp == 0 ? a[:enrolled] <=> b[:enrolled] : cmp
      }
      @count_filtered = @filtered.size
      @users = @filtered.paginate(:page => page, :per_page => per_page)
    else
      conditions = [ sql_search, { :search => "%#{params[:sSearch]}%" } ]
      @users = @total.find(:all,
                           :conditions => conditions,
                           :order => sql_order,
                           :joins => joins,
                           :group => 'users.id',
                           :offset => ((page-1) * per_page),
                           :limit => per_page)
      @filtered = @total.find(:all,
                              :conditions => conditions,
                              :joins => joins,
                              :group => 'users.id')
    end
    respond_to do |format|
      format.html {
        @users = @filtered.paginate(:page => page, :per_page => per_page)
        render :index
      }
      format.json {
        render :json => {
          'sEcho' => params[:sEcho].to_i,
          'iTotalRecords' => @total.size,
          'iTotalDisplayRecords' => @filtered.size,
          'aaData' => @users.collect { |x|
            j = x.as_json(:for => current_user)
            j[:public_profile_url] = public_profile_url(x.hex) if x.hex and x.hex.length > 0
            j
          }
        }
      }
    end
  end

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
    @page_title = 'My Account' if @user == current_user
  end

  def update
    @user = User.find params[:id]
    # If no mailing lists are selected, we don't get the parameter back from the browser
    params[:user]['mailing_list_ids'] = [] if not params[:user].has_key?('mailing_list_ids')

    if params[:user][:email] != @user.email then
      @user.log "Changed email address from '#{@user.email}' to '#{params[:user][:email]}'"
    end

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
    if not @user then
      flash[:error] = "User not found. Please try again."
      redirect_to root_path
      return
    end
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

  def switch_to
    target_uid = params[:switch_to_id].to_i
    return access_denied unless target_uid > 0
    if target_uid == User.find(target_uid).verify_userswitch_cookie(session[:switch_back_to])
      session[:user_id] = target_uid
      session.delete :real_uid
      session.delete :switch_back_to
    elsif current_user.is_admin?
      session[:real_uid] = current_user.id
      session[:switch_back_to] = current_user.create_userswitch_cookie
      session[:user_id] = target_uid
    else
      return access_denied
    end
    flash[:notice] = "Switched to #{User.find(session[:user_id]).full_name}'s account (id=#{session[:user_id]})"
    redirect_to '/'
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
