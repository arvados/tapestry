class Admin::UsersController < Admin::AdminControllerBase

  include Admin::UsersHelper
  include PhrccrsHelper

  def index
    if params[:completed]
      @users = User.has_completed(params[:completed])
      @result = "Searching for users that have completed '#{params[:completed]}': #{@users.size} found"
    elsif params[:enrolled]
      @users = User.enrolled
      @result = "Searching for enrolled users: #{@users.size} found"
    elsif params[:eligible_for_enrollment]
      @users = User.eligible_for_enrollment
      @result = "Searching for users eligible for enrollment: #{@users.size} found"
    elsif params[:inactive]
      @users = User.inactive
      @result = "Searching for inactive users: #{@users.size} found"
    elsif params[:screening_eligibility_group]
      @users = User.in_screening_eligibility_group(params[:screening_eligibility_group].to_i)
      @result = "Searching for users in eligibility group #{params[:screening_eligibility_group].to_i}: #{@users.size} found"
    elsif params[:name] or params[:email]
      if (params[:name] == '' and params[:email] == '') then
        @users = []
      else
        n = "%#{params[:name]}%" if params[:name] != ''
        e = "%#{params[:email]}%" if params[:email] != ''
        if params[:name] == '' then
          @users = User.find(:all, :conditions => [ "email LIKE ?" ,e])
        elsif params[:email] == '' then
          @users = User.find(:all, :conditions => [ "first_name LIKE ? or middle_name LIKE ? or last_name LIKE ?" ,n,n,n])
        else
          @users = User.find(:all, :conditions => [ "first_name LIKE ? or middle_name LIKE ? or last_name LIKE ? or email LIKE ?" ,n,n,n,e])
        end
      end
      @result = "Searching for users that match name '" + params[:name] + "' or email '" + params[:email] + "': #{@users.size} found"
    elsif params[:all]
      @users = User.all
      @result = "All users: #{@users.size} found"
    else
      @users = []
      @result = ''
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_for_users(@users), {
                     :filename    => 'PGP Application Users.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
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
end
