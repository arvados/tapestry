# validate locales
I18n.enforce_available_locales = true

# load our nested locales directory structure
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

# Available locales, and the default locale
I18n.available_locales = APP_CONFIG['available_locales']
I18n.default_locale = APP_CONFIG['default_locale']
