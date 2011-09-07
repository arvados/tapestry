class Admin::UsersController < Admin::AdminControllerBase

  include Admin::UsersHelper
  include PhrccrsHelper

  def index
    user_list_worker()
    respond_to do |format|
      format.html
      format.csv { send_data csv_for_users(@unpaginated_users), {
                     :filename    => 'PGP Application Users.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

  def log
    (@logs, @filtered) = log_worker(params)
  end

  def export_log
    (@logs, @filtered) = log_worker(params,0)
    report = StringIO.new

    header = ['When','Who','Log entry']

    CSV::Writer.generate(report) do |csv|
      csv << header
      @logs.each {|r|
        csv << [ r.created_at, r.user.nil? ? '' : r.user.hex, r.comment ]
      }
    end
    report.rewind

    send_data report.read,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=user_log.csv"
  end

  def active
  end

  def activity
    @user_logs = UserLog.find(:all, :limit => 10, :order => 'created_at desc')
    render :layout => "none"
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
    @user = User.find params[:id]
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
    @user = User.find params[:id]
    @user.is_admin = params[:user].delete(:is_admin)
    @user.is_test = params[:user].delete(:is_test)
    @user.can_unsuspend_self = params[:user].delete(:can_unsuspend_self)
    @user.researcher = params[:user].delete(:researcher)
    @user.researcher_onirb = params[:user].delete(:researcher_onirb)

    if (params[:user][:pgp_id] == '') then
      params[:user].delete(:pgp_id)
      @user.pgp_id = nil
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
      @user.log("Admin: #{current_user.full_name} changed first name from '#{@user.first_name}' to '#{params[:user][:first_name]}'")
    end
    if (@user.middle_name != params[:user][:middle_name]) then
      @user.log("Admin: #{current_user.full_name} changed middle name from '#{@user.middle_name}' to '#{params[:user][:middle_name]}'")
    end
    if (@user.last_name != params[:user][:last_name]) then
      @user.log("Admin: #{current_user.full_name} changed last name from '#{@user.last_name}' to '#{params[:user][:last_name]}'")
    end
    if (@user.email != params[:user][:email]) then
      @user.log("Admin: #{current_user.full_name} changed email address from '#{@user.email}' to '#{params[:user][:email]}'")
    end
    if (!@user.deactivated_at and params[:user][:deactivated_at]=='1')
      @user.deactivated_at = Time.now
      @user.log("Admin: #{current_user.full_name} account was deactivated")
    elsif (@user.deactivated_at and params[:user][:deactivated_at]=='0')
      @user.deactivated_at = nil
      @user.log("Admin: #{current_user.full_name} account was reactivated")
    end
    params[:user].delete :is_deactivated
    if (!@user.suspended_at and params[:user][:suspended_at]=='1')
      @user.suspended_at = Time.now
      @user.log("Admin: #{current_user.full_name} account was suspended")
    elsif (@user.suspended_at and params[:user][:suspended_at]=='0')
      @user.suspended_at = nil
      @user.log("Admin: #{current_user.full_name} account was unsuspended")
    end
    params[:user].delete :is_suspended

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to admin_users_url
    else
      @mailing_lists = MailingList.all
      render :action => 'edit' end
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
    redirect_to edit_admin_user_url(user)
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

  def google_phr_report
    @google_phrs = Ccr.find(:all,
       :joins => "INNER JOIN users ON users.id = ccrs.user_id",
       :conditions => "users.is_test = false",
       :order => "user_id, created_at")
  end

  def genetic_data_report
    @genetic_data = GeneticData.find(:all,
       :joins => "INNER JOIN users ON users.id = genetic_data.user_id",
       :conditions => "users.is_test = false",
       :order => "data_type, user_id")
  end

  def absolute_pitch_survey_questions
    aps = Survey.find_by_name("Absolute Pitch Survey")
    survey_users = User.find(:all, :conditions => 'absolute_pitch_survey_completion IS NOT NULL AND NOT is_test = true', :order => 'hex')
    questions = []
    if not aps.nil? then
      aps.survey_sections.each {|s|
        questions << s.survey_questions
      }
    end
    questions = questions.flatten.sort{|x,y| x.id <=> y.id }.select{|q| q.question_type != 'end'}

    report = StringIO.new

    CSV::Writer.generate(report) do |csv|
      questions.each_with_index { |q, i|
        csv << [ i+1, q.text ]
      }
    end
    report.rewind

    send_data report.read,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=absolute_pitch_survey_questions.csv"
  end

  def absolute_pitch_survey_export
    aps = Survey.find_by_name("Absolute Pitch Survey")
    survey_users = User.find(:all, :conditions => 'absolute_pitch_survey_completion IS NOT NULL AND NOT is_test = true', :order => 'hex')
    questions = []
    if not aps.nil? then
      aps.survey_sections.each {|s|
        questions << s.survey_questions
      }
    end
    questions = questions.flatten.sort{|x,y| x.id <=> y.id }.select{|q| q.question_type != 'end'}

    header = ['hexid']
    questions.each_with_index {|q, i| 
      header << "Question " + (i + 1).to_s
    }

    user_answers = []
    survey_users.each {|u|
      answers = [u.hex]
      questions.each_with_index {|q, i|
        answer = u.survey_answers.select { |a| a.survey_question_id == q.id }
        if answer.nil? || answer.length == 0
          answers << ''
        else
          answers << answer.map {|a| a.text}.join(";")
        end
      }
      user_answers << answers
    }

    report = StringIO.new

    CSV::Writer.generate(report) do |csv|
      csv << header
      user_answers.each {|r|
        csv << r
      }
    end
    report.rewind

    send_data report.read,
            :type => 'text/csv; charset=iso-8859-1; header=present',
            :disposition => "attachment; filename=absolute_pitch_survey_results.csv"
  end

  protected
  def user_list_worker
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
    elsif params[:ineligible_for_enrollment]
      @unpaginated_users = User.ineligible_for_enrollment
      @result = "Searching for users ineligible for enrollment"
    elsif params[:waitlisted]
      @unpaginated_users = User.waitlisted
      @result = "Searching for waitlisted users"
    elsif params[:inactive]
      @unpaginated_users = User.inactive
      @result = "Searching for inactive users"
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
      @result = "Test users"
    elsif params[:test]
      @unpaginated_users = User.is_test
      @result = "Test users"
    elsif params[:hex]
      if params[:hex] != '' then
        @unpaginated_users = User.find_all_by_hex(params[:hex])
      else
        @unpaginated_users = []
      end
       @result = "User with hex #{params[:hex]}"
    else
      @unpaginated_users = []
      @result = ''
    end

    # The extra to_a call is to work around bug #1349 in rails 2.2
    # See https://rails.lighthouseapp.com/projects/8994/tickets/1349-named-scope-with-group-by-bug 
    # TODO: after upgrade to 2.3, check if this is still needed. Ward, 2010-10-14
    @result += ": #{@unpaginated_users.to_a.size} found" if (@result != '')
    @users = @unpaginated_users.sort.paginate(:page => params[:page] || 1)
  end

  def log_worker(params,paginate=1)
    if params[:filter] then
      filter = '%' + params[:filter] + '%'
      @logs = UserLog.where('comment like ?',filter).sort { |x,y| y.created_at <=> x.created_at }
      @filtered = params[:filter]
    else
      @logs = UserLog.find(:all).sort { |x,y| y.created_at <=> x.created_at }
      @filtered = ''
    end
    if paginate == 1 then
      @logs = @logs.paginate(:page => params[:page] || 1, :per_page => 30)
    end
    return @logs, @filtered
  end

end
