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
    if ccr_list.length == 0
      # No PHR saved
      return
    end

    @ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] if File.file?(s) and not s.scan(/.+\/ccr(.+)\.xml/).empty? }

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

    @ccr = Nokogiri::XML(feed)
  end

end
