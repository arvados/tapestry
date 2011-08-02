#!/usr/bin/env ruby

# Example usage:
#
#   ./publicprofiledump.rb production script.sh index.html 1.2.3.4
#   sh script.sh
#   mv index.html dump-XXXXXX-XXXXXX
#
# Neither script.sh nor index.html may exist.
#
# Ward, 2010-10-14

# Default is development
production = ARGV[0] == "production"

if ARGV.size < 4 then
	puts "Usage: #{$0} production script-filename index-filename hostname"
	exit(1)
end

script_filename = ARGV[1]
index_filename = ARGV[2]
hostname = ARGV[3]

if File.exist?(script_filename) then
	puts "#{script_filename} may not exist. Aborting."
	exit(2)
end

if File.exist?(index_filename) then
	puts "#{index_filename} may not exist. Aborting."
	exit(3)
end

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

now = Time.now.strftime("%Y%m%d-%H%M%S")
dir = "dump-#{now}"

script = "mkdir #{dir}\ncd #{dir}\n"

index = "<html>\n<body>\n<h1>#{now}</h1>\n"

count = 0;

User.enrolled.each do |u|
	unless u.hex.nil?
		script += "wget http://#{hostname}/profile/#{u.hex} -O #{u.hex}.html; sleep 0.3\n"
		index += "<a href=\"#{u.hex}.html\">#{u.hex}</a><br/>\n"
		count += 1
	end
end

index += "</body>\n</html>\n"

File.open(index_filename, 'w') {|f| f.write(index) }
File.open(script_filename, 'w') {|f| f.write(script) }

puts "#{count} profiles found"
