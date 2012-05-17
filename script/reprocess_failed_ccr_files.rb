#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

# Reprocess CCR files that failed processing, if they have not been processed
# successfully since the failure was logged.
#
# Ward, 2012-05-17
 
include PhrccrsHelper

server = DRbObject.new nil, "druby://#{DRB_SERVER}:#{DRB_PORT}"

UserLog.where('comment like ?','%failed to process PHR%').each do |ul|
  @version = nil
	@matches = /\/ccr([^\/]*?)\.xml\)$/.match(ul.comment)
	@version = @matches[1] if not @matches.nil?
	if @version.nil? then
		STDERR.puts "Unable to parse version from UserLog with id #{ul.id} for user #{ul.user_id}, comment #{ul.comment}"
		next
	end

	@path = nil
	@matches = /(\/.+?\.xml)\)$/.match(ul.comment)
	@path = @matches[1] if not @matches.nil?

	next if @path.nil?
	
	if @version == ''	then
		# Invalid file - no version number found, it's just 'ccr.xml'. Don't bother reprocessing.
		STDERR.puts "Skipping file #{@path} for user #{ul.user_id}, comment #{ul.comment}"
		next
	end

	@ccr = Ccr.where('user_id = ? and version = ?',ul.user_id,@version).first

	if (@ccr.nil?) then
		STDERR.puts "Reprocessing #{@version} for user #{ul.user_id}"

    begin
      out = server.process_ccr(ul.user_id,IO.read(@path))
    rescue Exception => e
      STDERR.puts "DRB server error when trying to process a CCR: #{e.exception}"
			exit(1)
    end 

	else
		STDERR.puts "Already have a CCR object of #{@version} for user #{ul.user_id}, skipping"
	end


end

