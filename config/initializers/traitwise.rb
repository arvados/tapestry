class Traitwise
	@@server = "embed.traitwise.com"
	@@port = 443
	@@use_ssl = true;
	@@opts = {
		'host_signin' => TRAITWISE_LOGIN.to_s,
		'host_password' => TRAITWISE_PASSWORD.to_s,
		'embed_id' => 'pgp',
		'tags' => 'core-demographics',
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
    # Prior to Rails 2.3.2, the cookies hash contains elements with a string key 
    # and a CGI::Cookie object as value.
    # From Rails 2.3.2, the hash has elements with a string key and string value.
    # TODO: Fixme: when upgrading to Rails 2.3.2 or higher, make sure to adjust the code below:
    # cookies.each do |k,v|
    #   cookie_str += k[0].to_s + "=" + k[1].value.to_s + ";"
    # end
    if cookies
      cookies.each do |k|
        cookie_str += k[0].to_s + "=" + k[1].value.to_s + ";"
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
  		resp_from_tw, stream_from_tw = http.post(
  			url,
  			params,
  			{'User-Agent'=>request.env['HTTP_USER_AGENT']}
  		)
  		# This returns some cookies as Set-Cookie which have to be passed along
  		set_cookies = resp_from_tw.get_fields("Set-Cookie")
  		if set_cookies
  			set_cookies.each do |c|
  				c = CGI.unescape( c )
  				parts = c.match( /([^=]*)=([^;]*)/ )
  				cookies[parts[1]] = parts[2]
  			end
  		end
	  rescue Exception => e
      stream_from_tw = "We're sorry, the Traitwise service is currently unavailable. Please try again later."
      current_user.log("Error connecting to Traitwise service: #{ e } (#{ e.class })")
    end
	
		return stream_from_tw
		
	end
	
	def self.stream local_user_id, request, cookies, current_user=nil
		postArgs = ""
		@@opts.keys.each_with_index do |k,i|
			postArgs += (i==0 ? "" : "&") + k + "=" + URI.escape( @@opts[k].to_s )
		end
		
		return tw_post(
			"/hosted/stream", 
			postArgs + "&foreign_user_id=" + local_user_id.to_s + "&proxy_mode=rails",
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
