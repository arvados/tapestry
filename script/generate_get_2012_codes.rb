#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require 'digest/sha1'

(1..3000).each do |i|
  puts "PGP_" + Digest::SHA1.hexdigest(i.to_s + GET_2012_SECRET)[0,6].upcase
end 

