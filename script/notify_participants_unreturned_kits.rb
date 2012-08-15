#!/usr/bin/env ruby

# Notify participants who claimed a kit >= 21 days ago, but have not
# marked it as "returned".  (Unless, of course, we have already
# received it.)

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

DAYS_BEFORE_STALE = 10   # max cron interval
MAX_TO_SEND = 30         # per script invocation. use -1 for unlimited
n_to_send = 0
n_sent = 0

# Check up on participants who claimed a kit M..N days ago.

StudyParticipant.real.accepted.
  includes(:study, :user => [:kits, :user_logs]).
  where('studies.approved = ? and kits.owner_id = kits.participant_id and studies.days_before_unreturned_kit_reminder > 0 and kits.last_received < date_add(?,interval -studies.days_before_unreturned_kit_reminder day) and kits.last_received > date_add(?,interval -(studies.days_before_unreturned_kit_reminder + ?) day)',
        true,
        Time.now,
        Time.now,
        DAYS_BEFORE_STALE).
  each do |study_participant|

  user = study_participant.user
  study = study_participant.study
  user.kits.select { |kit|
    kit.study == study and
    kit.participant == kit.owner and
    kit.last_received < Time.now - study.days_before_unreturned_kit_reminder.days and
    kit.last_received > Time.now - (study.days_before_unreturned_kit_reminder + DAYS_BEFORE_STALE).days
  }.each do |kit|

    # Check whether the participant has already been reminded to
    # return this particular kit.

    if 0 == user.user_logs.
        select { |ul| ul.comment.match(/^Sent kit return reminder/) }.
        select { |ul| ul.info ? ul.info.kit_id == kit.id : ul.comment.match(/\##{kit.id}\b/) }.
        count

      Rails.logger.debug "Kit return reminder: Kit ##{kit.id} #{kit.name} #{user.full_name} last_received #{kit.last_received} logs.last #{kit.kit_logs.last.comment}"

      n_to_send += 1
      next if n_sent == MAX_TO_SEND
      n_sent += 1

      ul = UserLog.new(:user => user,
                       :user_comment => "Sent kit return reminder: #{kit.name}",
                       :comment => "Sent kit return reminder: ##{kit.id}",
                       :controlling_user => nil)
      ul.info.kit_id = kit.id
      ul.save!
      UserMailer.unreturned_kit_reminder(study_participant, kit).deliver
    end
  end
end

puts "Found #{n_to_send} to send; sent #{n_sent}" if n_to_send > 0
