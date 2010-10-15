#!/usr/bin/ruby1.8

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

# List name/e-mail address for enrolled users for whom we do not have a PHR.
# 
# Ward, 2010-10-15
  
include PhrccrsHelper

now = Time.now.strftime("%Y/%m/%d %H:%M:%S")

STDERR.puts "-- Enrolled users without PHR on file as of #{now} --"

count = 0

User.enrolled.each do |u|
  ccr_list = Dir.glob(get_ccr_path(u.id) + '*').reverse
  ccr_list.delete_if { |s| true if not File.file?(s) or s.scan(/.+\/ccr(.+)\.xml/).empty? }
  if ccr_list.length == 0 then
    puts "#{u.full_name} <#{u.email}>"
    count += 1
    next
  end 
  ccr_history = ccr_list.map { |s| s.scan(/.+\/ccr(.+)\.xml/)[0][0] }
  if ccr_history.length == 0 then
    puts "#{u.full_name} <#{u.email}>"
    count += 1
    next
  end
end

STDERR.puts "-- Found #{count} users --"
