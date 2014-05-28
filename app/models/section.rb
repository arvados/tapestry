module Section
  CONFIG_KEY = 'enabled_sections'

  SIGNUP = :signup
  PUBLIC_DATA = :public_data
  PUBLIC_PROFILE = :public_profile
  ENROLL = :enroll
  GOOGLE_SURVEYS = :google_surveys
  # Leave SAMPLES disabled if PUBLIC_DATA is disabled (PH 2014-04-11)
  SAMPLES = :samples
  CCR = :ccr

  def self.include_section?(section)
    APP_CONFIG[Section::CONFIG_KEY].include?( section.to_s ) ||
      APP_CONFIG[Section::CONFIG_KEY].include?( section )
  end

end
