#!/usr/bin/env ruby

# Example usage:
#
#   ./mark_kits_as_sent.rb production <inputfilename> <user_id>
#
# Ward, 2011-11-25

# Default is development
production = ARGV[0] == "production"

if ARGV.size < 3 then
	puts "Usage: #{$0} production input_filename user_id"
	exit(1)
end

input_filename = ARGV[1]
user_id = ARGV[2]

if not File.exist?(input_filename) then
	puts "#{input_filename} must exist. Aborting."
	exit(2)
end

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

if User.find(user_id).nil? then
	puts "User with id #{user_id} not found. Aborting."
	exit(3)
end

def mark_as_sent(kit, user)
	if kit.last_mailed.nil?
  	kit.last_mailed = Time.now()
  	kit.shipper_id = user.id
  	# Nobody 'owns' the kit at the moment
  	kit.owner = nil 
  	kit.save
  	kit.samples.each do |s| 
    	s.last_mailed = Time.now()
    	s.owner = nil 
    	s.save
   	 SampleLog.new(:actor => user, :comment => 'Sample sent', :sample_id => s.id).save
  	end 
  	# Log this
  	KitLog.new(:actor => user, :comment => 'Kit sent', :kit_id => kit.id).save
		return true
	else
		puts "#{kit.name} already marked as sent on #{kit.last_mailed} by #{kit.shipper.first_name} #{kit.shipper.last_name}"
		return false 
	end
end

count = 0
f = File.open(input_filename) or die "Unable to open file..."
contentsArray = f.each_line { |line| 
  line.chomp!
  k = Kit.find_by_name(line)
  if not k.nil? then
    result = mark_as_sent(k,User.find(user_id))
    count = count + 1 if result
  end
}

puts "#{count} kits marked as sent"


