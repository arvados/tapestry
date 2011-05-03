PgpEnroll::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_view.debug_rjs             = false
  config.action_controller.perform_caching = true

  # Do care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  ActionMailer::Base.smtp_settings = {
    :domain => "my-dev.personalgenomes.org",
    :address => 'outgoing.personalgenomes.org'
  }

  ROOT_URL = 'my-dev.personalgenomes.org'
  ADMIN_EMAIL = 'PGP <general@personalgenomes.org>'
  SYSTEM_EMAIL = 'sysadmin@clinicalfuture.com'
  
  ENV['RECAPTCHA_PUBLIC_KEY'] = 'yyyyyyyyyyyyyyyyyyyyyyyy-xxxxxxxx'
  ENV['RECAPTCHA_PRIVATE_KEY'] = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyy'
  
  GOOGLE_HEALTH_URL = "https://www.google.com/h9"
  
  LATEST_CONSENT_VERSION = 'v20110222'
  
  DRB_SERVER = '127.0.0.1'
  DRB_PORT = '9900'
  DRB_CALLBACK_SOURCE_IP = '10.6.3.27'
  
  TRAITWISE_LOGIN = "traitwise@personalgenomes.org"
  TRAITWISE_PASSWORD = "xxxxxxxx"
  
end

