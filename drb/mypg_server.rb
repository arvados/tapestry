#!/usr/bin/env ruby

# Default to development
mode = 'development'
mode = 'production' if (ARGV[0] == "production")

ENV["RAILS_ENV"] = "development"
ENV["RAILS_ENV"] = "production" if mode == 'production'

# Flush output immediately
STDOUT.sync = true

# Add the directory this script lives in to the library search path
$:.unshift File.join(File.dirname(__FILE__))

require 'drb'
require 'MyPG'
require 'yaml'

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

if @config.has_key?(mode) then
  @config = @config[mode]
else
  puts "Mode #{mode} not found in Config file - aborting."
  exit 1
end

path = '/data'
MYPG_DRB_URI = "druby://#{@config['host']}:#{@config['port']}"
puts mode.upcase + ", listening at #{MYPG_DRB_URI}"

aServerObject = MyPG.new(path)
DRb.start_service(MYPG_DRB_URI, aServerObject)
DRb.thread.join # Don't exit just yet!

