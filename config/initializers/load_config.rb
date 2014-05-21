CONFIG_DEFAULTS_FILENAME = "#{Rails.root}/config/config.defaults.yml.erb"

# Load the configuration defaults first
if not File.exists? CONFIG_DEFAULTS_FILENAME
  die("Could not find #{CONFIG_DEFAULTS_FILENAME}")
end

def load_yaml_erb(filename)
  YAML.load( ERB.new( File.read( filename ) ).result )
end

config_defaults = load_yaml_erb(CONFIG_DEFAULTS_FILENAME)

default_config_common = config_defaults['common']
default_config_environment = config_defaults[Rails.env]

default_config_common ||= {}
default_config_environment ||= {}

if File.exists?("#{::Rails.root.to_s}/config/config.yml")
  site_config_environment = YAML.load_file("#{::Rails.root.to_s}/config/config.yml")[::Rails.env.to_s]
  site_config_environment ||= {}
  APP_CONFIG = default_config_common.merge(default_config_environment).merge(site_config_environment)
else
  APP_CONFIG = default_config_common.merge(default_config_environment)
end

# the recaptcha code requires environment variables to be set
ENV['RECAPTCHA_PUBLIC_KEY'] = APP_CONFIG['recaptcha_public_key']
ENV['RECAPTCHA_PRIVATE_KEY'] = APP_CONFIG['recaptcha_private_key']

# This is for backwards compatibility; remove this once all uses of the old constants
# are eradicated from the codebase.
APP_CONFIG.each do |k,v|
  eval("#{k.upcase} = v")
end
