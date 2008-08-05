class Admin::UsersController < Admin::AdminControllerBase
  include Admin::UsersHelper

  def index
    @users = User.all
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
  end

  def update
    @user = User.find params[:id]
    @user.is_admin = params[:user][:is_admin]

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to admin_users_url
    else
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
