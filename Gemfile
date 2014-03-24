# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'
source 'http://gems.github.com'

ruby '1.8.7'
gem 'rails', '3.0.20'

gem 'mysql'
gem 'cancan'

gem "paperclip", "~> 2.3.16"        # File attachments
gem 'gchart'
gem 'nokogiri', '~> 1.5.6'
gem 'gdata', :require => 'gdata'
gem 'carmen', '~> 0.2.13'          # A repository of geographic regions
gem 'hoptoad_notifier', "~> 2.3"   # POSTs to a server (like Redmine) when exceptions occur (deprecated, now replaced by airbrake gem)
gem 'will_paginate'
gem 'validates_email_format_of', :git => 'git://github.com/alexdunae/validates_email_format_of.git'

gem 'i18n', '0.5.3'

gem 'rails3_acts_as_paranoid', "~> 0.0.9"
gem 'cure_acts_as_versioned', :require => 'acts_as_versioned'
gem 'userstamp'

gem 'factory_girl_rails', "~> 1.3.0"
gem 'mocha', :require => false     # Mocking and stubbing library
gem 'recaptcha', :require => "recaptcha/rails"
gem 'limerick_rake'                # Long-since deprecated. For which tasks do we need this? The rake db:bootstrap:load makes the tests work, but there's also a db:seed_enrollment_steps that could make that work
gem 'verhoeff', "~> 2.0.0"         # Verhoeff checksums used by Kit model
gem 'fastercsv'
gem 'acts_as_api'
group :test do
  gem "shoulda", "~> 2.11.3"
  gem 'redgreen'
end

gem "gmaps4rails", "~> 1.3.0"
gem 'RedCloth'
gem 'cells'

