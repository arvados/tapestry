#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "development"
ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

require 'drb'

# attach to the DRb server
remote_array = DRbObject.new nil, 'druby://127.0.0.1:9901'

u = User.find(1)

out = remote_array.get_ccr(u.id, u.authsub_token, nil, GOOGLE_HEALTH_URL + '/feeds/profile/default')

puts out 

puts "DONE"

