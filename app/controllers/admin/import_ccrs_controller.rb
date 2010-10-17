class Admin::ImportCcrsController < Admin::AdminControllerBase
  include PhrccrsHelper

  def index
    if request.post?
      #update family_members flag first
      users = User.find(:all)
      @user_update_count = 0
      users.each {|u|
        if !u.family_relations.blank?
          u.has_family_members_enrolled = 'yes'
          u.save
          @user_update_count += 1
        end
      }

      ccr_files = {}
      data_dir = '/data/' + ROOT_URL + '/ccr'
      @failed_imports = []
      @successful_imports = []

      Dir[data_dir + '/**/*.xml'].each { |f|      
        m = /.+ccr(.+)\/ccr(.+)\.xml/.match(f)
	#begin
	  user_id = m[1].gsub('/','').to_i
	  ccr_version = m[2]	 
	  ccr = parse_xml_to_ccr_object(f)
	  ccr.user_id = user_id
	  ccr.version = ccr_version
	  ccr.save
	  @successful_imports << user_id.to_s + ' ' + ccr_version + '<br />'
	#rescue
	#  @failed_imports << f
	#  break
        #end	
      }    

      flash[:notice] = "Successfully imported " + @successful_imports.length.to_s + " ccrs"
    end
  end
end
