#!/usr/bin/env ruby

# Process a file with bounce reports and contact a named proxy for each participant that
# is found.
#
# Format of input file: one report per line, first column (RT ticket #) is ignored:
# 5642|2020-03-24 23:19:43|example42@example.com|554 delivery error: dd Requested mail action aborted - user unknown
#
# Ward, 2020-03-30

if ARGV.length < 2
	puts "Syntax: $0 <path-to-file> <admin-user-id>"
	exit(1)
end

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require 'time'

outputfile = ARGV[0] + '-' + Time.now.to_i.to_s

puts "Results in #{outputfile}"

File.open(outputfile,'a') do |output|

  File.open(ARGV[0]).each do |line|
  	line.chomp!
  	tmp = line.split("|",4)
  	u = User.find_by_email(tmp[2])
  	if u.nil?
  		output.puts(line + "|skipped, user not found")
  	  next
  	end
  	if u.suspended_at != nil
  		output.puts(line + "|user #{u.id}: skipped, user suspended")
  	  next
  	end

  	if u.user_logs.where(:created_at => tmp[1]).size != 0
  		output.puts(line + "|user #{u.id}: skipped, already recorded and processed")
  		next
  	end

  	ul = UserLog.new()

  	ul.user = u
  	ul.created_at = tmp[1]
  	ul.updated_at = tmp[1]
  	ul.comment = "E-mail to #{tmp[2]} bounced: #{tmp[3]}".truncate(255)
    ul.save!

		recent_proxy_request = false
		u.user_logs.each do |ul|
			if ul.comment =~ /^Sent a proxy request/ and ul.created_at > 7.days.ago
  			recent_proxy_request = true
  			break
			end
		end

		if recent_proxy_request
      output.puts(line + "|user #{u.id}: recorded bounce but did not contact proxy since a proxy was e-mailed less 7 days ago")
      next
    end

  	np = u.named_proxies.first
  	if np != nil
  		UserMailer.deliver_user_bounce_proxy_notification(u,np)
      ul = UserLog.new()
      ul.user = u
      ul.comment = "Sent a proxy request to #{np.name} <#{np.email}>: e-mail bounce, please ask participant to log in and update e-mail address"
      ul.controlling_user_id = ARGV[1]
  		ul.save!
  		output.puts(line + "|user #{u.id}: logged bounce and notified named proxy #{np.id}: #{np.name} <#{np.email}>")
			next
  	end	
  	output.puts(line + "|user #{u.id}: logged bounce but no named proxy defined")
  end

end

puts "Results in #{outputfile}"
