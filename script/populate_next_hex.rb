#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

count = 0

while NextHex.all.count < 1000 do
  begin code = "hu%06X" % rand(2**24) end while User.unscoped.find_by_hex(code)
  n = NextHex.new()
  n.hex=code
  n.save!
  count += 1
end

puts
puts "Created #{count} new records in the NextHex table."
puts
