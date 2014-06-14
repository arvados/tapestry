#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require "faster_csv"

CSV_FILE_PATH = File.join(File.dirname(__FILE__), "output.csv")

# writing to a file
FasterCSV.open(CSV_FILE_PATH, "w") do |csv|
  csv << %w[first last email address_line_1 address_line_2 address_line_3 city state zip phone]
  User.enrolled.each do |u|
    s = u.shipping_address
    if s.nil? then
      csv << [u.first_name,u.last_name,u.email,'','','','','','','']
    else
      csv << [u.first_name,u.last_name,u.email,s.address_line_1,s.address_line_2,s.address_line_3,s.city,s.state,s.zip,s.phone]
    end
  end
end
puts File.read(CSV_FILE_PATH)

