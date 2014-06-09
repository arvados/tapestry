class GeographicInformationController < ApplicationController

  def model_name
    "User"
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

end
