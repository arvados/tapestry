#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require 'digest/sha1'

users = User.enrolled

users.each do |user|
  puts "PGP_" + Digest::SHA1.hexdigest(user.hex + GET_2013_SECRET)[0,6].upcase + "," + user.hex
end 

# We have a cutoff now; only enrolled PGP participants at the moment the script
# is run will get a free pass.

#NextHex.all.each do |nh|
#  puts "PGP_" + Digest::SHA1.hexdigest(nh.hex + GET_2013_SECRET)[0,6].upcase + ","
#end

