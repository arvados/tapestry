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

  def enroll
    params[:eligible_for_enrollment] = true
    if request.method == :put then
      enrolled = 0
      if params[:number] then
        User.eligible_for_enrollment.limit(params[:number]*1).each do |u|
          u.promote!
          u.log("Enrolled by #{current_user.full_name}")
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
    if ccr_list.length > 0
      @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }
    end
  end

  def edit
    @user = User.find params[:id]
    @mailing_lists = MailingList.all
    ccr_list = Dir.glob(get_ccr_path(@user.id) + '*').reverse
    if ccr_list.length > 0
      @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }
    end
  end

  def update
    @user = User.find params[:id]
    @user.is_admin = params[:user].delete(:is_admin)

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
      @unpaginated_users = User.has_completed(params[:completed])
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
      @unpaginated_users = User.all
      @result = "All users"
    else
      @unpaginated_users = []
      @result = ''
    end

    @result += ": #{@unpaginated_users.size} found" if (@result != '')
    # For some reason User.all.paginate does nothing. Work around that here. Ward, 2010-10-09
    if @unpaginated_users.size != User.all.size then
      @users = @unpaginated_users.paginate(:page => params[:page] || 1)
    else
      @users = User.paginate(:page => params[:page] || 1)
    end
  end

end
