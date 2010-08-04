class GeographicInformationController < ApplicationController

  def show
    @user = current_user
    render :action => 'edit'
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
