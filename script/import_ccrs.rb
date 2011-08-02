#!/usr/bin/env ruby

# This script parses CCR xml files in the data directory and saves them as
# objects in the database.
#
# It is safe to run this script multiple times, it will not insert the same
# record twice.
#
# Si, 2010-10-20

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

include PhrccrsHelper

#update family_members flag first
puts "Updating family relationship status"

users = User.find(:all)
user_update_count = 0
users.each {|u|
if !u.family_relations.blank?
  u.has_family_members_enrolled = 'yes'
  u.save
  user_update_count += 1
end
}
puts user_update_count.to_s + " users updated"

puts "Starting CCR import"

ccr_files = {}
data_dir = '/data/' + ROOT_URL + '/ccr'
failed_imports = []
successful_imports = []

ccr_files_to_import = Dir[data_dir + '/**/*.xml']
puts ccr_files_to_import.length.to_s + " CCRs found in " + data_dir
ccr_files_to_import.each { |f|
  m = /.+ccr(.+)\/ccr(.+)\.xml/.match(f)
  #begin
  user_id = m[1].gsub('/','').to_i

  u = User.find(user_id)
  if u.nil?
    puts f.to_s
    puts m[1]
    puts "nil"
  end
  next if u.nil?

  ccr_version = m[2]
  # We don't want duplicates
  Ccr.find_by_user_id_and_version(user_id,ccr_version).destroy unless Ccr.find_by_user_id_and_version(user_id,ccr_version).nil?

  ccr = parse_xml_to_ccr_object(f)
  ccr.user_id = user_id
  ccr.version = ccr_version
  begin
    ccr.save
  rescue
    puts 'Error saving ccr version: ' + ccr_version + " for user: " + user_id.to_s
  end
  successful_imports << user_id.to_s + ' ' + ccr_version + '<br />'
  #rescue
  #  @failed_imports << f
  #  break
  #end
  if (successful_imports.length % 10 == 0)
    puts successful_imports.length.to_s + " imported..."
  end
}

puts "Successfully imported " + successful_imports.length.to_s + " ccrs"
