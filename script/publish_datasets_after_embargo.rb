#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

# Publish datasets when 30 day notice period ends.  Avoid publishing
# datasets that are too old, though; if something unusual happened (a
# participant who was deactivated at the end of the 30 days has just
# been reactivated?) it should be dealt with manually.

Dataset.
  where('published_at is null and published_anonymously_at is null and seen_by_participant_at < ? and seen_by_participant > ?', Time.now - 30.days, Time.now - 32.days).
  joins(:participant).
  merge(User.enrolled.not_suspended.not_deactivated).
  each do |ds|
  ds.published_at = Time.now
  ds.save!
  ds.submit_to_get_evidence!(:make_public => true)
  ds.participant.log("Automatically published dataset #{ds.name} (#{ds.id})")
end
