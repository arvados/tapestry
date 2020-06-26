ActionMailer::Base.default_url_options[:host] = ROOT_URL
ActionMailer::Base.default_url_options[:protocol] = APP_CONFIG["root_url_scheme"].gsub(/[:\/]*/,'')
