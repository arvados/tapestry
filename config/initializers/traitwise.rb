class Traitwise
	@@server = "embed.traitwise.com"
	@@port = 443
	@@use_ssl = true;
	@@basic_opts = {
		'host_signin' => TRAITWISE_LOGIN.to_s,
		'host_password' => TRAITWISE_PASSWORD.to_s
  }
	@@opts = {
		'xtags' => 'core-demographics',
		'charity_id' => 1,
		'suppress_survey_intro_panel' => false,
		'suppress_traitwise_panels' => false,
		'suppress_add_a_question_button' => false,
		'suppress_comments' => false,
		'suppress_search_box' => false,
		'suppress_discussions_tab' => false,
		'suppress_public_questions_tab' => false,
		'suppress_my_surveys_tab' => true,
		'suppress_login' => true,
		'suppress_tabs' => false,
		'include_restart_link' => false,
		'suppress_jquery_load' => true,
		'suppress_jquery_ui_load' => false,
		'suppress_jquery_qtip_load' => false,
		'suppress_jquery_flash_load' => false
	}
	
	def self.proxy url, request, cookies
		# PASS ajax requests along back to the TW server
	
		http = Net::HTTP.new( @@server, @@port )
		http.use_ssl = @@use_ssl

		cookie_str = ""
    if cookies
      cookies.each do |k,v|
        cookie_str += k.to_s + "=" + v.to_s + ";"
      end
		else
			cookies = {}
		end
				
		headers = { 'Cookie'=>cookie_str, 'User-Agent'=>request.env['HTTP_USER_AGENT'] }
		
		if request.post?
			resp_from_tw, data_from_tw = http.post(url,request.raw_post,headers)
		else
			resp_from_tw, data_from_tw = http.get(url,headers)
		end

		#h = @resp_from_tw.to_hash()
		set_cookies = resp_from_tw.get_fields("Set-Cookie")
		if set_cookies
			set_cookies.each do |c|
				c = CGI.unescape( c )
				parts = c.match( /([^=]*)=([^;]*)/ )
				cookies[parts[1]] = parts[2]
			end
		end
		
		return data_from_tw
	end

	def self.tw_post url, params, request, cookies, current_user=nil
		http = Net::HTTP.new( @@server, @@port )
		http.use_ssl = @@use_ssl
    begin
      if not request.nil? then
        user_agent = request.env['HTTP_USER_AGENT']
      else
        user_agent = ''
      end
  		resp_from_tw, stream_from_tw = http.post(
  			url,
  			params,
  			{'User-Agent'=> user_agent}
  		)
      if not cookies.nil? then
    		# This returns some cookies as Set-Cookie which have to be passed along
    		set_cookies = resp_from_tw.get_fields("Set-Cookie")
    		if set_cookies
    			set_cookies.each do |c|
    				c = CGI.unescape( c )
    				parts = c.match( /([^=]*)=([^;]*)/ )
    				cookies[parts[1]] = parts[2]
    			end
    		end
      end
	  rescue Exception => e
      stream_from_tw = "We're sorry, the Traitwise service is currently unavailable. Please try again later."
      if not current_user.nil? then
        current_user.log("Error connecting to Traitwise service: #{ e } (#{ e.class })")
      else
        STDERR.puts "Error connecting to Traitwise service: #{ e } (#{ e.class })"
      end
    end
	
		return stream_from_tw
		
	end
	
	def self.stream local_user_id, embed_id, request, cookies, tags, current_user=nil
		postArgs = ""
		@@basic_opts.keys.each_with_index do |k,i|
			postArgs += (i==0 ? "" : "&") + k + "=" + URI.escape( @@basic_opts[k].to_s )
		end
		@@opts.keys.each_with_index do |k,i|
			postArgs += "&" + k + "=" + URI.escape( @@opts[k].to_s )
		end

		postArgs += "&embed_id=#{embed_id}"
		
		return tw_post(
			"/hosted/stream", 
			postArgs + "&foreign_user_id=" + local_user_id.to_s + "&tags=" + URI.escape(tags.to_s) + "&proxy_mode=rails",
			request,
			cookies,
			current_user
		)
	end



	def self.report local_user_id, source, tags, request, cookies, current_user=nil
		postArgs = ""
		@@basic_opts.keys.each_with_index do |k,i|
			postArgs += (i==0 ? "" : "&") + k + "=" + URI.escape( @@basic_opts[k].to_s )
		end

		if not local_user_id.nil? then
			postArgs += "&filter_by_foreign_user_id=" + URI.escape( local_user_id.to_s )
		end

		if not source.nil? then
			postArgs += "&filter_by_source=" + URI.escape( source.to_s )
		end

		if not tags.nil? then
			postArgs += "&filter_by_tags=" + URI.escape( tags.to_s )
		end

		return tw_post(
			"/hosted/report",
			postArgs + "&format=csv&proxy_mode=rails",
			request,
			cookies,
			current_user
		)
	end

	def self.merge_user old_local_user_id, new_local_user_id, request, cookies
		return tw_post(
			"/hosted/merge_user_data",
			"host_signin=" + @@login.to_s + "&host_password=" + @@password.to_s + "&old_foreign_user_id=" + old_foreign_user_id + "&new_foreign_user_id=" + new_foreign_user_id,
			request,
			cookies,
			current_user
		)
	end		

end
