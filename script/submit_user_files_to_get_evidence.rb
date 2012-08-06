#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

UserFile.
  suitable_for_get_evidence.
  includes(:user).
  where('locator is null').
  each do |x|
  x.store_in_warehouse
  if x.locator
    x.submit_to_get_evidence!(:make_public => false,
                              :name => "#{x.user.hex} (#{x.name})",
                              :controlled_by => x.user.hex)
  end
end
