require File.expand_path('../boot', __FILE__)

require 'rails/all'

if RUBY_VERSION >= '1.9'
  # Silently ignore any "require 'jcode'" by any module (e.g., gdata)
  # -- use built-in unicode support instead.
  class Object
    def require(*args)
      if args[0] == 'jcode' then true else super(*args) end
    end
  end
end

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Tapestry
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
    config.active_record.observers = :user_observer, :kit_observer, :permission_observer, :dataset_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w(jquery-1.7.2.min jquery-ui-1.8.11.custom.min jquery.dataTables.min jquery-custom-extensions rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.autoload_paths << "#{Rails.root}/lib"

    # Do not wrap form labels with the 'field_with_errors' wrapper,
    # and use a *span* instead of a div for the form input fields.
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      include ActionView::Helpers::RawOutputHelper
      if /<label for=/.match(html_tag) then
        html_tag.html_safe
      else
        raw %(<span class="field_with_errors">#{html_tag}</span>)
      end
    end

    # Specify the directory that we hope will eventually allow overriding any Tapestry behaviour.
    # The folders inside this directory will exactly mimic those in Rails.root.
    # By default this is a subfolder of Rails.root called "site_specific".
    # This default override folder can itself be overridden using the environment variable TAPESTRY_OVERRIDE_PATH.
    # This folder and any subfolders, files, etc. can be left empty if no override behaviour is desired.
    # Currently only app/views is supported.
    # PH: It is my impression that if one wants to use the automatic-reloading development feature of Rails that
    # this path can't be outside of Rails.root, but I am not 100% sure on this yet.
    override_path = ENV['TAPESTRY_OVERRIDE_PATH'] || "#{Rails.root}/site_specific"

    # Add a second view path (normally only "app/views" is in the list of view paths).
    # Anything in this directory matching the app/views directory tree will override the default.
    # (PH: Note that I already tried:
    #      config.paths.app.unshift "#{override_path}/app"
    # and it did not seem to work as expected. The major app subfolders seem to each need to have their own explicit addition here.)
    # (PH: I also tried to do this with lib and it also had unpredictable results. Use these paths with caution.)
    config.paths.app.views.unshift "#{override_path}/app/views"

    # Let's use an analogous set-up for lib
    config.autoload_paths += ["#{override_path}/lib"]

    # Trying to use config.paths.config to override locales doesn't work as expected, and anyway for locales there are better
    # mechanisms that merge translations from all locale files.
    # At the risk of it being misleading, the so-called override path can be used for these too, since it makes
    # sense to put _all_ site-specific files in the same directory.
    config.i18n.load_path += Dir[File.join(override_path, 'config', 'locales', '*.{rb,yml}')]

  end
end
