# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.smtp_settings = {
  :domain => "my.personalgenomes.org",
  :address => 'outgoing.personalgenomes.org'
}

ROOT_URL = 'my.personalgenomes.org'
ADMIN_EMAIL = 'PGP <general@personalgenomes.org>'
SYSTEM_EMAIL = 'sysadmin@clinicalfuture.com'

ENV['RECAPTCHA_PUBLIC_KEY'] = 'yyyyyyyyyyyyyyyyyyyyyyyy-xxxxxxxx'
ENV['RECAPTCHA_PRIVATE_KEY'] = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyy'

GOOGLE_HEALTH_URL = "https://www.google.com/health"

LATEST_CONSENT_VERSION = 'v20100331'
