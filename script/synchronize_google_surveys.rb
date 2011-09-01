#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

GoogleSurvey.where(:open => true).each { |x|
  ok, error_message = x.synchronize!
  $stderr.puts "#{x.name} (id=#{x.id}): #{error_message}" if !ok
}
