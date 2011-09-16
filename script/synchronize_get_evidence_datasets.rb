#!/usr/bin/env ruby

# Default is development
production = ARGV[0] == "production"

ENV["RAILS_ENV"] = "production" if production

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'
require 'net/http'

User.pgp_ids.each { |u|
  target = "http://evidence.personalgenomes.org/#{u.hex}"
  url = "http://evidence.personalgenomes.org/genomes?display_genome_id=#{u.hex}&json=1"
  begin
    json = Net::HTTP.get URI.parse(url)
    report = ActiveSupport::JSON.decode(json)
    if report and report['status']['status'] == 'finished'
      sha1 = report['input_sha1']
      ds = Dataset.find_by_sha1(sha1) || Dataset.find_by_location(target) || Dataset.new(:sha1 => sha1)
      ds.participant = u
      ds.name = report['header_data']['Name']
      ds.location = target
      ds.save
    end
  rescue
    nil
  end
}
