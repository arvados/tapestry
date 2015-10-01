# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'
source 'http://gems.github.com'

ruby '1.8.7'
gem 'rails', '3.0.20'

gem 'mysql'
gem 'cancan'

# Paperclip: file attachments
gem "paperclip", "~> 2.3.16"
gem 'gchart'
gem 'nokogiri', '~> 1.5.11'
gem 'gdata', :require => 'gdata'
# Carmen: A repository of geographic regions
gem 'carmen', '~> 0.2.13'
gem 'will_paginate'
gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'

gem 'i18n', '0.5.3'

gem 'rails3_acts_as_paranoid', "~> 0.0.9"
gem 'cure_acts_as_versioned', :require => 'acts_as_versioned'
gem 'userstamp'

gem 'factory_girl_rails', "~> 1.3.0"
# Mocha: Mocking and stubbing library
gem 'mocha', :require => false
gem 'recaptcha', :require => "recaptcha/rails"
# Limerick_rake: Long-since deprecated. Still apparently a little useful because of the rake db:bootstrap(:load) task which can quickly give us some sample content areas and exam questions.
gem 'limerick_rake'
# Verhoeff: checksums used by Kit model
gem 'verhoeff', "~> 2.0.0"
gem 'fastercsv'
gem 'acts_as_api'
group :test do
  gem "shoulda", "~> 2.11.3"
  gem 'redgreen'
end

gem "gmaps4rails", "~> 1.3.0"
gem 'RedCloth'
# using a specific version of cells (3.11.0, released yesterday, throws up a Syntax error)
gem 'cells', "~> 3.10.1"
# dependency of cells which throws up a syntax error on 0.0.11 and 0.0.12
# 2015-06-10 nico .. bundler complains about any version > 0.0.6 
gem 'uber', "0.0.6"

gem 'oauth2'
gem 'system_timer'
