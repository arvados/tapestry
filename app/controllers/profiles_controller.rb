class ProfilesController < ApplicationController
  layout 'profile'
  
  skip_before_filter :login_required, :only => [:public]

  include PhrccrsHelper

  def public
    @user = User.find_by_hex(params[:hex])
    # Invalid hex code
    return if not @user

    @family_members = @user.family_relations

    ccr_list = Dir.glob(get_ccr_path(@user.id) + '*').reverse
    ccr_list.delete_if { |s| true if not File.file?(s) or s.scan(/.+\/ccr(.+)\.xml/).empty? }

    if ccr_list.length == 0
      # No PHR saved
      return
    end

    @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }

    version = params[:version]
    if version && !version.empty?
      for i in 0.. ccr_list.length - 1 do
      	  if @ccr_history[i] == version
	     feed = File.new(ccr_list[i])
	     @current_version = version
	     break
	  end
      end
    else
      feed = File.new(ccr_list[0])
      @current_version = @ccr_history[0]
    end

    @ccr = Ccr.find(:first, :conditions => {:user_id => @user.id, :version => @current_version })
    # Old way of parsing the CCR on disk below
    #@ccr = Nokogiri::XML(feed)
  end

end
