# Load the configuration defaults first
if not File.exists?("#{::Rails.root.to_s}/config/config.defaults.yml")
  die("Could not find #{::Rails.root.to_s}/config/config.defaults.yml")
end

default_config_common = YAML.load_file("#{::Rails.root.to_s}/config/config.defaults.yml")['common']
default_config_environment = YAML.load_file("#{::Rails.root.to_s}/config/config.defaults.yml")[::Rails.env.to_s]

if File.exists?("#{::Rails.root.to_s}/config/config.yml")
  APP_CONFIG = default_config_common.merge(default_config_environment).merge(YAML.load_file("#{::Rails.root.to_s}/config/config.yml")[::Rails.env.to_s])
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
