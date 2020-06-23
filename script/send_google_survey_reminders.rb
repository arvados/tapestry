#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

GoogleSurvey.where('open = 1', 'reminder_email_frequency != ""').each do |gs|
  gs.google_survey_reminders.each do |gsr|
    if gsr.last_sent.nil? or Time.now() + gsr.frequency.days < gsr.last_sent
      $stderr.puts "Sending google survey reminder (id #{gsr.id}) to #{gsr.user.email}"
      gsr.last_sent = Time.now().utc
      gsr.save!
      UserMailer.google_survey_reminder(gsr.user,gs).deliver
    else
      $stderr.puts "Skipping google survey reminder (id #{gsr.id}) to #{gsr.user.email}, now is #{Time.now().utc.strftime("%F %T %Z")}, last sent at #{gsr.last_sent}, frequency is #{gsr.frequency} day(s)"
    end
  end
end
