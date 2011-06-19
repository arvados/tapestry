# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PgpEnroll::Application.initialize!

require 'stringio'
require 'csv'
require 'drb'

# Recaptcha gem has funky file naming - the stuff we need is in the rails.rb file
require "recaptcha/rails"
