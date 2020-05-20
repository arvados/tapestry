# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'

ruby '1.8.7'
gem 'rails', '5.2.4.3'
gem 'rake', '~> 10.4' # because rake 11 requires ruby 1.9.3

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

gem 'rails3_acts_as_paranoid', '~> 0.0.9'
gem 'cure_acts_as_versioned', '>= 0.6.3', :require => 'acts_as_versioned'
gem 'userstamp'

group :test, :development do
  gem 'factory_girl_rails', '>= 1.7.0'
  # factory_girl >= 3 requires ruby >= 1.9.2, so for now we pin to <3
  gem 'factory_girl', '>= 2.6.4', '< 3.0.0'
  # Mocha: Mocking and stubbing library
  gem 'mocha', :require => false
end

# Once we move to ruby 2.x, revert to the latest version of the recaptcha gem
# the cure-recaptcha gem works around a bug in recaptcha 0.4.0, which is the last
# version that supports ree 1.8.7
gem 'cure-recaptcha', '~> 0.4.1', :require => "recaptcha/rails"
# Limerick_rake: Long-since deprecated. Still apparently a little useful because of the rake db:bootstrap(:load) task which can quickly give us some sample content areas and exam questions.
gem 'limerick_rake'
# Verhoeff: checksums used by Kit model
gem 'verhoeff', "~> 2.0.0"
gem 'fastercsv'
gem 'acts_as_api', '>= 0.4.2'
group :test do
  gem "shoulda", "~> 2.11.3"
  gem 'redgreen'
end

gem "gmaps4rails", "~> 1.3.0"
gem 'RedCloth'
# using a specific version of cells (3.11.0, released yesterday, throws up a Syntax error)
gem 'cells', '~> 3.10.1'
# dependency of cells which throws up a syntax error on 0.0.11 and 0.0.12
# 2015-06-10 nico .. bundler complains about any version > 0.0.6 
gem 'uber', "0.0.6"
gem 'cocaine', '0.5.7'

gem 'oauth2', '<= 0.9.3' # because jwt because google-api-client because arvados
gem 'jwt', '< 1.0.0' # because arvados because google-api-client
gem 'highline', "1.6.21"
gem 'net-ssh', "2.9.2"
gem 'system_timer'
gem 'faraday', '~> 0.9' # because google-api-client

gem 'addressable', '2.3.8' # because newer versions require ruby 1.9
gem 'arvados', '>= 0.1.20180302192246'
gem 'google-api-client', '0.7.1' # because retriable because ruby 1.9
gem 'retriable', '< 2' # because ruby 1.9
