class RealNamesController < ApplicationController

  def model_name
    "User"
  end

  def add
    @user = current_user
  end

  def remove
  end

  def update
    @user = current_user
    if params["commit"] =~ /^Yes/
      @new_value = false
      @new_value = true if params["commit"] =~ /^Yes, add/
      @user.real_name_public = @new_value
      @user.save
      if @new_value
        @user.log("Real name added to public profile",nil,nil,"Real name added to public profile")
      else
        @user.log("Real name removed from public profile",nil,nil,"Real name removed from public profile")
      end
    end
    redirect_to public_profile_url(:hex => current_user.hex)
  end

end
