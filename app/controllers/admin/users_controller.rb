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

  def active
  end

  def activity
    @user_logs = UserLog.find(:all, :limit => 10, :order => 'created_at desc')
    render :layout => "none"
  end

  def enroll
    params[:eligible_for_enrollment] = true
    if request.method == :put then
      enrolled = 0
      if params[:number] then
        User.eligible_for_enrollment.limit(params[:number]*1).each do |u|
          u.promote!
          u.log("Enrolled by #{current_user.full_name}")
          UserMailer.deliver_enrollment_decision_notification(u)
          enrolled += 1
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

  protected

  def user_list_worker
    if params[:completed]
      @unpaginated_users = User.has_completed(params[:completed]).exclude_test_users
      @result = "Searching for users that have completed '#{params[:completed]}'"
    elsif params[:enrolled]
      @unpaginated_users = User.enrolled
      @result = "Searching for enrolled users"
    elsif params[:eligible_for_enrollment]
      @unpaginated_users = User.eligible_for_enrollment
      @result = "Searching for users eligible for enrollment"
    elsif params[:ineligible_for_enrollment]
      @unpaginated_users = User.ineligible_for_enrollment
      @result = "Searching for users ineligible for enrollment"
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
      @unpaginated_users = User.exclude_test
      @result = "All users"
    elsif params[:test]
      @unpaginated_users = User.test
      @result = "Test users"
    else
      @unpaginated_users = []
      @result = ''
    end

    @result += ": #{@unpaginated_users.size} found" if (@result != '')
    @users = @unpaginated_users.paginate(:page => params[:page] || 1)
  end

end
