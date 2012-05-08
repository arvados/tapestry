#!/usr/bin/env ruby

rails_env = ARGV.shift          # development, staging, or production

if ARGV.size < 1 then
  puts "Usage: #{$0} {production|staging|development} feed_url ..."
  exit 1
end

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

ENV["RAILS_ENV"] = rails_env
require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

ARGV.each do |source|
  ok = false
  sync_time = Time.now

  rss = []
  open(source) do |s|
    rss = RSS::Parser.parse(s.read, false)
  end

  rss.items.each do |i|
    newpost = ExternalBlogPost.new(:feed_url => source,
                                   :posted_at => Time.parse(i.pubDate.to_s),
                                   :retrieved_at => sync_time,
                                   :post_url => i.link,
                                   :title => i.title,
                                   :description => i.description)
    if newpost.save or
        ExternalBlogPost.where('feed_url = ? and post_url = ?',
                               source, i.link).
        first.
        update_attributes(:posted_at => Time.parse(i.pubDate.to_s),
                          :retrieved_at => sync_time,
                          :title => i.title,
                          :description => i.description)
      ok = true
    end
  end

  if ok
    ExternalBlogPost.where('feed_url = ? and retrieved_at < ?',
                           source, sync_time - 30).destroy_all
  end
end
