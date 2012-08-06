#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

todo = Dataset.where('status_url <> ? and not processing_stopped', '') |
  UserFile.where('status_url <> ? and not processing_stopped', '')
todo.each do |x|
  ok = x.update_processing_status! rescue nil
  if ok
    if x.processing_stopped
      puts "#{x.class.to_s} ##{x.id} stopped: #{x.processing_status[:status]}"
    end
  else
    puts "#{x.class.to_s} ##{x.id} status check failed"
  end
end
