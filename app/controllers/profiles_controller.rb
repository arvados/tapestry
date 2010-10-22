class ProfilesController < ApplicationController
  layout 'profile'
  
  skip_before_filter :login_required, :only => [:public]

  include PhrccrsHelper

  def public
    @user = User.find_by_hex(params[:hex])
    # Invalid hex code
    return if not @user

    @family_members = @user.family_relations

    @ccr = Ccr.find(:first, :conditions => {:user_id => @user.id}, :order => 'version DESC')
  end
end
