#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

TraitwiseSurvey.where(:open => true).each { |x|
  @sit = SpreadsheetImporterTraitwise.where('traitwise_survey_id = ?',x.id).first
  ok, error_message = @sit.synchronize!(nil,nil,nil)
  $stderr.puts "#{x.name} (id=#{x.id}): #{error_message}" if !ok
}
