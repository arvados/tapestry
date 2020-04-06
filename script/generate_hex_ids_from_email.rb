#!/usr/bin/env ruby

# Given a file with a list of e-mail addresses, one per line, generate a list
# of hex IDs for participants (STDOUT). Skips e-mail addresses for which there
# s no match (with notice on STDERR).
#
# Ward, 2020-04-06

if ARGV.length < 1
	puts "Syntax: $0 <path-to-file>"
	exit(1)
end

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

File.open(ARGV[0]).each do |line|
	line.chomp!
	tmp = line.split("|",4)
	u = User.find_by_email(line)
	if u.nil?
		STDERR.puts("No participant found with e-mail address #{line}, skipping")
	  next
	end
	if ! u.enrolled?
		STDERR.puts("Participant found with e-mail address #{line} but they are not enrolled, skipping")
	  next
	end
	puts(u.hex)
end

