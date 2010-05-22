class Admin::UsersController < Admin::AdminControllerBase

  include Admin::UsersHelper

  def index
    if params[:completed]
      @users = User.has_completed(params[:completed])
    elsif params[:inactive]
      @users = User.inactive
    elsif params[:screening_eligibility_group]
      @users = User.in_screening_eligibility_group(params[:screening_eligibility_group].to_i)
    else
      @users = User.all
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_for_users(@users), {
                     :filename    => 'PGP Application Users.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

  def edit
    @user = User.find params[:id]
    @mailing_lists = MailingList.all
  end

  def update
    @user = User.find params[:id]
    @user.is_admin = params[:user].delete(:is_admin)

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to admin_users_url
    else
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
end
