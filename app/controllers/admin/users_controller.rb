class Admin::UsersController < Admin::AdminControllerBase

  include Admin::UsersHelper
  include PhrccrsHelper

  def index
    user_list_worker()
    respond_to do |format|
      format.html
      format.csv { 
        @timestamp = Time.now().strftime("%Y%m%d-%H%M%S")
        if params[:failed_eligibility_survey] then
          send_data csv_for_failed_eligibility_survey, {
                     :filename    => "#{@timestamp}-hupgp_failed_eligibility_survey.csv",
                     :type        => 'application/csv',
                     :disposition => 'attachment' } 
        else
          send_data csv_for_users(@unpaginated_users), {
                     :filename    => "#{@timestamp}-hupgp_users.csv",
                     :type        => 'application/csv',
                     :disposition => 'attachment' }
        end
      }
    end
  end

  def log
    (@logs, @filtered) = log_worker(params)
  end

  def active
  end

  def activity
    @user_logs = UserLog.find(:all, :limit => 10, :order => 'created_at desc')
    render :layout => "none"
  end

  def enroll_single_user
    flash.delete(:error)
    flash.delete(:notice)
    @redir_dest = params[:redir_dest]
    @redir_dest ||= admin_twins_users_url
    if request.put? then
      if params[:id] then
        u = User.find(params[:id]*1)
        if u.nil? then
          flash[:error] = "User not found"
        else
          begin
            u.promote!
          rescue Exceptions::MissingStep => exception then
            u.log("Could not be enrolled: #{exception.message}")
            flash[:error] = '' if flash[:error].nil?
            flash[:error] += "Could not enroll #{u.full_name} (#{u.id}): #{exception.message}<br/>"
          else
            if u.screening_survey_response.monozygotic_twin == 'willing' then
              u.log("Enrolled by #{current_user.full_name} -- manual enrollment with willing twin")
            else
              u.log("Enrolled by #{current_user.full_name}")
              flash[:notice] = "#{u.full_name} was enrolled"
            end
            UserMailer.deliver_enrollment_decision_notification(u)
          end
        end
      else
        flash[:error] = "Missing parameter"
      end
    else
      flash[:error] = "Wrong method call"
    end
    redirect_to @redir_dest
  end

  def enroll
    flash.delete(:error)
    flash.delete(:notice)
    params[:eligible_for_enrollment] = true
    if request.put? then
      enrolled = 0
      if params[:number] then
        User.eligible_for_enrollment.limit(params[:number]*1).each do |u|
          begin
            u.promote!
          rescue Exceptions::MissingStep => exception then
            u.log("Could not be enrolled: #{exception.message}")
            flash[:error] = '' if flash[:error].nil?
            flash[:error] += "Could not enroll #{u.full_name} (#{u.id}): #{exception.message}<br/>"
          else
            u.log("Enrolled by #{current_user.full_name}")
            UserMailer.deliver_enrollment_decision_notification(u)
            enrolled += 1
          end
        end
      end
      if enrolled != 1 then
        flash[:notice] = "#{enrolled} users were enrolled"
      else
        flash[:notice] = "#{enrolled} user was enrolled"
      end
    end
    user_list_worker()
  end

  def show
    if params[:id].to_s.length == 40 then
      # /admin/users/f65ea621688341215688354afc8321893a84cae5
      @user = User.locate_unenrolled_identifier(params[:id])
    else
      # /admin/users/9999
      begin
        @user = User.find(params[:id])
      rescue
        @user = nil
      end
    end
    if @user.nil? then
      flash[:error] = 'Invalid user id specified'
      redirect_to admin_users_url
      return
    end
    ccr_list = Dir.glob(get_ccr_path(@user.id) + '*').reverse
    ccr_list.delete_if { |s| true if not File.file?(s) or s.scan(/.+\/ccr(.+)\.xml/).empty? }
    if ccr_list.length > 0
      @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }
    end
  end

  def edit
    @user = User.find params[:id]
    @mailing_lists = MailingList.all
    ccr_list = Dir.glob(get_ccr_path(@user.id) + '*').reverse
    ccr_list.delete_if { |s| true if not File.file?(s) or s.scan(/.+\/ccr(.+)\.xml/).empty? }
    if ccr_list.length > 0
      @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }
    end
  end

  def update
    @log_messages = []

    @user = User.find params[:id]
    @user.controlling_user = current_user
    @user.is_admin = params[:user].delete(:is_admin)
    @user.is_test = params[:user].delete(:is_test)
    if (@user.deceased != params[:user][:deceased]) then
      if not @user.deceased and params[:user][:deceased] == '1' then
        @log_messages << "Marked as deceased by admin"
      elsif @user.deceased and params[:user][:deceased] == '0' then
        @log_messages << "Marked as alive by admin"
      end
    end
    @user.deceased = params[:user].delete(:deceased)
    @user.can_reactivate_self = params[:user].delete(:can_reactivate_self)
    @user.researcher = params[:user].delete(:researcher)
    @user.researcher_onirb = params[:user].delete(:researcher_onirb)


    if (params[:user][:pgp_id] == '') then
      params[:user].delete(:pgp_id)
      if not @user.pgp_id.nil? then
        @log_messages << "Admin removed PGP#{@user.pgp_id}"
        @user.pgp_id = nil
      end
    end
    if (params[:user][:security_question] == '') then
      params[:user].delete(:security_question)
      @user.security_question = nil
    end
    if (params[:user][:security_answer] == '') then
      params[:user].delete(:security_answer)
      @user.security_answer = nil
    end

    if (@user.first_name != params[:user][:first_name]) then
      @log_messages << "Admin changed first name from '#{@user.first_name}' to '#{params[:user][:first_name]}'"
    end
    if (@user.middle_name != params[:user][:middle_name]) then
      @log_messages << "Admin changed middle name from '#{@user.middle_name}' to '#{params[:user][:middle_name]}'"
    end
    if (@user.last_name != params[:user][:last_name]) then
      @log_messages << "Admin changed last name from '#{@user.last_name}' to '#{params[:user][:last_name]}'"
    end
    if (@user.email != params[:user][:email]) then
      @log_messages << "Admin changed email address from '#{@user.email}' to '#{params[:user][:email]}'"
    end
    if (@user.pgp_id.to_s != params[:user][:pgp_id].to_s) then
      if @user.pgp_id.nil? and params[:user][:pgp_id] != '' then
        @log_messages << "Admin assigned PGP#{params[:user][:pgp_id]}"
      else
        @log_messages << "Admin changed PGP# from PGP#{@user.pgp_id} to PGP#{params[:user][:pgp_id]}"
      end
    end
    if (!@user.deactivated_at and params[:user][:deactivated_at]=='1')
      @user.deactivated_at = Time.now
      @log_messages << "Admin deactivated account"
    elsif (@user.deactivated_at and params[:user][:deactivated_at]=='0')
      @user.deactivated_at = nil
      @log_messages << "Admin reactivated account"
    end
    params[:user].delete :is_deactivated
    if (!@user.suspended_at and params[:user][:suspended_at]=='1')
      @user.suspended_at = Time.now
      @log_messages << "Admin suspended account"
    elsif (@user.suspended_at and params[:user][:suspended_at]=='0')
      @user.suspended_at = nil
      @log_messages << "Admin unsuspended account"
    end
    params[:user].delete :is_suspended

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      if not @log_messages.empty? then
        @log_messages.each do |lm|
          @user.log(lm)
        end
      end
      redirect_to admin_users_url
    else
      @mailing_lists = MailingList.all
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find params[:id]

    if @user.destroy
      flash[:notice] = 'User deleted.'
      redirect_to admin_users_url
    else
      render :action => 'index'
    end
  end

  def promote
    user = User.find params[:id]
    user.promote!
    user.reload
    flash[:notice] = "User promoted"
    redirect_to admin_user_url(user)
  end

  def activate
    @user = User.find params[:id]

    if @user.activate!
      flash[:notice] = 'User activated.'
      redirect_to admin_users_url
    else
      render :action => 'index'
    end
  end

  def ccr
    @user = User.find params[:id]

    version = params[:version]
    if version && !version.empty?
      ccr_list = Dir.glob(get_ccr_path(@user.id) + '*').reverse     
      ccr_list.delete_if { |s| true if not File.file?(s) or s.scan(/.+\/ccr(.+)\.xml/).empty? }
      ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }      
      for i in 0.. ccr_list.length - 1 do
        if ccr_history[i] == version
          feed = File.new(ccr_list[i])
          break
        end
      end
      @ccr = Nokogiri::XML(feed)
    else
      flash[:error] = 'No version specified'
    end
  end

  def demote
    user = User.find params[:id]
    user.demote!
    user.reload
    flash[:notice] = "User demoted"
    redirect_to :action => 'edit'
  end

  def twins
    @twins = User.eligible_for_enrollment_with_willing_twin
  end

  def ineligible
    @ineligible = Hash.new(0)
    User.ineligible_for_enrollment.each do |u|
      u.ineligible_for_enrollment.each do |r|
        @ineligible[r] += 1
      end
    end
  end

  def trios
    @trios = User.trios
  end

  def families
    @participants_with_family_members = User.joins(:family_relations).where('is_confirmed is true and relation in ("monozygotic/identical twin","parent","sibling","grandparent","aunt/uncle","half sibling","cousin or more distant","not genetically related (e.g. husband/wife)")').group('user_id having count(*) > 0')
  end

  def google_phr_report
    @google_phrs = Ccr.find(:all,
       :joins => "INNER JOIN users ON users.id = ccrs.user_id",
       :conditions => "users.is_test = false",
       :order => "user_id, created_at")
  end

  def user_files_report
    @user_files = UserFile.find(:all,
       :joins => "INNER JOIN users ON users.id = user_files.user_id",
       :conditions => "users.is_test = false",
       :order => "data_type, user_id")
  end

  protected
  def user_list_worker
    @show = Hash.new()
    @show['pgp_id'] = true
    @show['name'] = true
    @show['email'] = true
    @show['administrator'] = true
    @show['researcher'] = true
    @show['researcher_on_irb'] = true
    @show['edit_link'] = true
    @show['delete_link'] = true
    if params[:completed]
      @unpaginated_users = User.has_completed(params[:completed]).real
      @result = "Searching for users that have completed '#{params[:completed]}'"
    elsif params[:enrolled]
      @unpaginated_users = User.enrolled
      @result = "Searching for enrolled users"
    elsif params[:pgp_id]
      @unpaginated_users = User.pgp_ids
      @result = "Searching for enrolled users with PGP #"
    elsif params[:eligible_for_enrollment]
      @unpaginated_users = User.eligible_for_enrollment
      @result = "Searching for users eligible for enrollment"
    elsif params[:eligible_for_enrollment_with_willing_twin]
      @unpaginated_users = User.eligible_for_enrollment_with_willing_twin
      @result = "Searching for users eligible for enrollment with willing twin"
    elsif params[:ineligible_for_enrollment]
      @unpaginated_users = User.ineligible_for_enrollment
      @result = "Searching for users ineligible for enrollment (submitted application)"
    elsif params[:at_or_in_exam]
      @unpaginated_users = User.not_enrolled.has_completed('screening_survey_results').has_not_completed('content_areas')
      @result = "Searching for users who are at the exam step in the enrollment process"
    elsif params[:failed_eligibility_survey]
      @unpaginated_users = User.failed_eligibility_survey
      @result = "Searching for users ineligible for enrollment (failed eligibility survey)"
      @show['pgp_id'] = false
      @show['email'] = false
      @show['administrator'] = false
      @show['researcher'] = false
      @show['researcher_on_irb'] = false
      @show['edit_link'] = false
      @show['delete_link'] = false
      @show['name'] = true
      @show['unique_hash'] = true
      @show['ineligibility_reasons'] = true
    elsif params[:waitlisted]
      @unpaginated_users = User.waitlisted
      @result = "Searching for waitlisted users"
    elsif params[:inactive]
      @unpaginated_users = User.inactive
      @result = "Searching for inactive users"
      @show['active'] = true
      @show['activate_link'] = true
    elsif params[:suspended]
      @unpaginated_users = User.suspended
      @result = "Searching for suspended users"
    elsif params[:deactivated]
      @unpaginated_users = User.deactivated
      @result = "Searching for deactivated users"
    elsif params[:name] or params[:email]
      # Test users are *not* excluded from this
      if (params[:name] == '' and params[:email] == '') then
        @unpaginated_users = []
      else
        n = "%#{params[:name]}%" if params[:name] != ''
        e = "%#{params[:email]}%" if params[:email] != ''
        if params[:name] == '' then
          @unpaginated_users = User.find(:all, :conditions => [ "email LIKE ?" ,e])
        elsif params[:email] == '' then
          @unpaginated_users = User.find(:all, :conditions => [ "first_name LIKE ? or middle_name LIKE ? or last_name LIKE ?" ,n,n,n])
        else
          @unpaginated_users = User.find(:all, :conditions => [ "first_name LIKE ? or middle_name LIKE ? or last_name LIKE ? or email LIKE ?" ,n,n,n,e])
        end
      end
      @result = "Searching for users that match name '" + params[:name] + "' or email '" + params[:email]
    elsif params[:all]
      @unpaginated_users = User.real
      @result = "All users"
    elsif params[:researcher]
      @unpaginated_users = User.researcher
      @result = "Researchers"
    elsif params[:test]
      @unpaginated_users = User.is_test
      @result = "Test users"
      @show['active'] = true
      @show['activate_link'] = true
    elsif params[:hex]
      if params[:hex] != '' then
        @unpaginated_users = User.find_all_by_hex(params[:hex])
      else
        @unpaginated_users = []
      end
      @result = "User with hex #{params[:hex]}"
    elsif params[:unenrolled_identifier]
      if params[:unenrolled_identifier] != '' then
        u = User.locate_unenrolled_identifier(params[:unenrolled_identifier])
        if not u.nil? then
          @unpaginated_users = [ u ]
        else
          @unpaginated_users = []
        end
      else
        @unpaginated_users = []
      end
      @result = "User with unique identifier #{params[:unenrolled_identifier]}"
    else
      @unpaginated_users = []
      @result = ''
    end

    @result += ": #{@unpaginated_users.length} found" if (@result != '')
    @users = @unpaginated_users.sort.paginate(:page => params[:page] || 1)
  end

  def log_worker(params,paginate=1)
    filter = '%'
    @filtered = params[:filter] || ''
    if params[:filter]
      filter = '%' + params[:filter] + '%'
    end

    @logs = UserLog.
      includes(:user).
      where('comment like ? or users.hex like ?', filter, filter).
      order('user_logs.created_at desc')
    if paginate == 1
      @logs = @logs.paginate(:page => params[:page] || 1, :per_page => 30)
    end
    return @logs, @filtered
  end

end
