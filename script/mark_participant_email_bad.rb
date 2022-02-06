#!/usr/bin/env ruby

# Example usage:
#
#   ./mark_participant_email_bad.rb production <inputfilename>
#
# Ward, 2022-02-06

# Default is development
production = ARGV[0] == "production"

if ARGV.size < 2 then
	puts "Usage: #{$0} production input_filename"
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

count = 0
f = File.open(input_filename) or die "Unable to open file..."
contentsArray = f.each_line { |line| 
  line.chomp!
  u = User.find_by_email(line)
  if not u.nil?
    if !u.bad_email
      u.bad_email = true
      puts "Participant with e-mail address #{line} marked as bad e-mail"
      u.save!
      ul = UserLog.new()
      ul.user = u
      ul.comment = "Script (bounce processing) marked email address '#{u.email}' as bad"
      ul.save!
      count = count + 1
    else
      puts "Skipping participant with e-mail address #{line}: already marked as bad e-mail"
    end
  else
    puts "No participant found with e-mail address #{line}"
  end
  k = Kit.find_by_name(line)
  if not k.nil? then
    result = mark_as_sent(k,User.find(user_id))
    count = count + 1 if result
  end
}

puts "#{count} user e-mail addresses marked as bad"
