#!/usr/bin/env ruby

# Send out Safety Questionnaire reminders for people who have not filled one
# out in the last 3 months. Repeat reminders every 6 weeks. 
#
# Ward, 2010-09-08

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

User.find(:all).each do |u|
  next if u.enrolled.nil? # shortcut for speed
  if (u.user_logs.find_by_comment('Sent PGP Safety Questionnaire Reminder').nil?) or 
     (u.user_logs.find_by_comment('Sent PGP Safety Questionnaire Reminder') and
      6.weeks.ago > u.user_logs.find(:last, :conditions => "comment = 'Sent PGP Safety Questionnaire Reminder'").created_at) then
    if not u.has_recent_safety_questionnaire then
      # The UserMailer call will also add the 'Sent PGP Safety Questionnaire Reminder' user log entry
      UserMailer.deliver_safety_questionnaire_reminder(u)
      puts "Sent PGP Safety Questionnaire Reminder for #{u.full_name} (#{u.id})"
    end
  end
end

