#!/usr/bin/env ruby

# This script automatically updates all users who signed a certain version of
# the consent form to the latest version. Use caution - this should only be done
# when there are no changes to the consent document other than an update of the
# annual approval stamp. Be sure to update PREVIOUS_CONSENT_VERSION before you
# run this script.
#
# Ward, 2012-02-21

#PREVIOUS_CONSENT_VERSION = 'v20130221'

if not defined? PREVIOUS_CONSENT_VERSION
  puts "Please define PREVIOUS_CONSENT_VERSION"
  exit 1
end

# Default is development
production = ARGV[0] == "production"
staging = ARGV[0] == "staging"

ENV["RAILS_ENV"] = "production" if production
ENV["RAILS_ENV"] = "staging" if staging

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

count = 0
User.all.each do |u|
	
  if u.documents.kind('consent', APP_CONFIG['latest_consent_version']).empty? and 
     not u.documents.kind('consent', PREVIOUS_CONSENT_VERSION).empty? then
      count += 1
  		puts u.full_name
      puts u.id
      puts u.consent_version
      u.consent_version = APP_CONFIG['latest_consent_version']
      u.documents << Document.new(:keyword => 'consent', :version => APP_CONFIG['latest_consent_version'], :timestamp => Time.now())
       u.log('Signed full consent form version ' + APP_CONFIG['latest_consent_version'] + ' (auto)')
      u.save
  end
end

puts "All:   " + User.all.size.to_s
puts "Match: " + count.to_s
