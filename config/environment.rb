# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PgpEnroll::Application.initialize!

require 'stringio'
require 'csv'
require 'drb'

