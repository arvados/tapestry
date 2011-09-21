
require 'rubygems'
require 'net/http'
require 'uri'
require 'cgi'
require 'thread'
require 'find'
require 'yaml'

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
include PhrccrsHelper

# Flush STDOUT/STDERR immediately
STDOUT.sync = true
STDERR.sync = true

class WorkObject
	attr_accessor :action
	attr_accessor :user_id
	attr_accessor :authsub_token
	attr_accessor :etag
	attr_accessor :ccr_profile_url
end

class MyPG

	attr_reader :data_path
	attr_reader :config

	def initialize(data_path)
		@data_path = data_path

		@config = read_config()

		mode = ENV['RAILS_ENV']

		if @config.has_key?(mode) then
			@config = @config[mode]
		else
			puts "Mode #{mode} not found in Config file - aborting."
	    exit 1
		end

    # These keys are required in the config file
    @required_keys = ['callback_port','callback_host','workers']
    exit 1 if not required_keys_exist(@required_keys)

		@queue = Queue.new
		@consumers = (1..@config['workers']).map do |i|
		  Thread.new("consumer #{i}") do |name|
		    begin
		      work = @queue.deq
					begin
			      print "#{name}: started work for user #{work.user_id}: #{work.action}\n"
						if work.action == 'get_ccr' then
							get_ccr_worker(work)
						end
			      print "#{name}: finished work for user #{work.user_id}: #{work.action}\n"
			      sleep(rand(0.1))
					rescue Exception => e
						puts "Trapped exception in worker"
            puts "#{work.action}: job failed: #{e.inspect()}"
    				callback('userlog',work.user_id,
              { "message" => "#{work.action}: job failed: #{e.inspect()}", 
                "user_message" => "Error: job failed." } )
					end
		    end until work == :END_OF_WORK
		  end
		end
	end

  def required_keys_exist(required)
    all_found = true
    required.each do |r|
  		if not @config.has_key?(r) then
 			  puts "Error: required key '#{r}' not found for mode #{ENV['RAILS_ENV']} in config file."
        all_found = false
  		end
    end
    return all_found
  end

  def read_config
    file = File.dirname(__FILE__) + '/MyPG.yml'
    @config = Hash.new()
    if not FileTest.file?(file)
      puts "Config file #{file} not found - aborting."
			exit 1
    else
      @config = YAML::load_file(file)
			if (@config == false) then
				puts "Config file #{file} corrupted or empty - aborting."
	      exit 1
			end
    end 
    return @config
  end

  def get_ccr_worker(work)
    client = GData::Client::Base.new
    client.authsub_token = work.authsub_token
    client.authsub_private_key = private_key
    if work.etag
      client.headers['If-None-Match'] = work.etag
    end
    feed = client.get(work.ccr_profile_url).body
    ccr = Nokogiri::XML(feed)
    updated = ccr.xpath('/xmlns:feed/xmlns:updated').inner_text

    if (updated == '1970-01-01T00:00:00.000Z') then
      callback('userlog',work.user_id,
        { "message" => "get_ccr: PHR at Google Health is empty, it has not been downloaded.", 
          "user_message" => "Your PHR at Google Health is empty, it has not been downloaded." } )
      return
    end

    ccr_filename = get_ccr_filename(work.user_id, true, updated)
    if !File.exist?(ccr_filename)
      callback('userlog',work.user_id, 
        { "message" => "get_ccr: Downloaded PHR (#{ccr_filename})", 
          "user_message" => "Downloaded PHR." } )
    else
      callback('userlog',work.user_id, 
        { "message" => "get_ccr: Downloaded and replaced PHR (#{ccr_filename})", 
          "user_message" => "Updated PHR." } )
    end
    outFile = File.new(ccr_filename, 'w')
    outFile.write(feed)
    outFile.close
    callback('ccr_downloaded',work.user_id, { "updated" => updated, "ccr_filename" => ccr_filename })
  end

	def get_ccr(user_id, authsub_token, etag, ccr_profile_url)
		work = WorkObject.new()
		work.action = 'get_ccr'
		work.authsub_token = authsub_token
		work.etag = etag
		work.ccr_profile_url = ccr_profile_url
		work.user_id = user_id
		@queue.enq(work)
		return 0
	end

	def callback(type,user_id,args) 
	
    if args.class == Hash then
      params = "?"
      args.each do |k,v|
   		  params += "#{k}=" + CGI.escape(v) + "&" 
      end
      params += "user_id=#{user_id}"
    else
 		  params = "/#{user_id}?message=" + CGI.escape(args)
    end

    url = "http://#{@config['callback_host']}:#{@config['callback_port']}/drb/#{type}#{params}"

		# Do callback
		puts "Calling #{url}"
 		Net::HTTP.get URI.parse(url)
	end

	def pretty_size(size)
		return nil if size.nil?
		if size.to_i > 1024 then
			# KB
			size = (size / 1024)
			if size.to_i > 1024 then
				# MB
				size = (size / 1024)
				if size.to_i > 1024 then
					size = (size / 1024)
					if size.to_i > 1024 then
						# GB
						size = (size / 1024)
						if size.to_i > 1024 then
							# TB
							size = (size / 1024)
						else
							return sprintf("%8.2f T",size)
						end
					else
						return sprintf("%8.2f G",size)
					end
				else
					return sprintf("%8.2f M",size)
				end
			else
				return sprintf("%8.2f K",size)
			end
		else
			return sprintf("%5d     ",size)
		end
	end

  # Returns location of private key used to sign Google Health requests
  def private_key
    if File.exists?(File.dirname(__FILE__) + '/../config/private_key.pem')
      return File.dirname(__FILE__) + '/../config/private_key.pem'
    else
      return nil
    end
  end

end


