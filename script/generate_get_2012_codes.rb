#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require 'digest/sha1'

users = User.enrolled

buf = ''
header_row = ['Invite code','E-mail','First name','Last name']

CSV.generate_row(header_row, header_row.size, buf)
users.each do |user|
  row = []
  row.push "PGP_" + Digest::SHA1.hexdigest("20120325" + user.email)[0,6].upcase
  row.push user.email
  row.push user.first_name
  row.push user.last_name
  CSV.generate_row(row, row.size, buf)
end 
puts buf 

