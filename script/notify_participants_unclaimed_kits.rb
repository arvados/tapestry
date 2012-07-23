#!/usr/bin/env ruby

# Notify participants who had a kit mailed to them 21 days ago, but
# have not claimed a kit.

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

DAYS_BEFORE_REMINDER = 21
DAYS_BEFORE_STALE = 31          # days_before_reminder + max cron interval
MAX_TO_SEND = 30                # per script invocation. use -1 for unlimited
n_to_send = 0
n_sent = 0

Study.approved.each do |study|

  # Only check up on participants whose last kit was sent 21..31 days
  # ago.

  study.study_participants.real.accepted.
    where('kit_last_sent_at and kit_last_sent_at < ? and kit_last_sent_at > ?',
          Time.now - DAYS_BEFORE_REMINDER.days,
          Time.now - DAYS_BEFORE_STALE.days).
    includes(:user => [:kits, :user_logs]).
    each do |study_participant|

    # Find participants who [a] have claimed no kits for this study;
    # and [b] have not already been reminded about this particular
    # kit.  Avoid reminding a participant twice for the same study,
    # unless two kits were actually sent.

    if study_participant.user.kits.select { |k| k.study_id == study.id }.count == 0 and
        study_participant.user.user_logs.
        select { |ul| ul.comment.match(/^Sent kit claim reminder/) }.
        select { |ul| ul.info and ul.info.study_id == study.id and ul.info.kit_last_sent_at == study_participant.kit_last_sent_at }.
        count == 0

      n_to_send += 1
      next if n_sent == MAX_TO_SEND
      n_sent += 1

      ul = UserLog.new(:user => study_participant.user,
                       :user_comment => "Sent kit claim reminder: #{study.name}",
                       :comment => "Sent kit claim reminder: ##{study.id}",
                       :controlling_user => nil)
      ul.info.study_id = study.id
      ul.info.kit_last_sent_at = study_participant.kit_last_sent_at
      ul.save!
      UserMailer.unclaimed_kit_reminder(study_participant).deliver
    end
  end
end

puts "Found #{n_to_send} to send; sent #{n_sent}" if n_to_send > 0
