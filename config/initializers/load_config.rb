default_config_filepath = File.join(Rails.root, 'config', 'config.defaults.yml')
site_config_filepath = File.join(Rails.root, 'config', 'config.yml')

# Load the configuration defaults first
if not File.exists?(default_config_filepath)
  die("Could not find #{default_config_filepath}")
end

default_config = YAML::load(ERB.new(IO.read(default_config_filepath)).result)

default_config_common = default_config['common']
default_config_environment = default_config[::Rails.env.to_s]

default_config_common ||= {}
default_config_environment ||= {}

if File.exists?(site_config_filepath)
  site_config_environment = YAML::load(ERB.new(IO.read(site_config_filepath)).result)[::Rails.env.to_s]
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
