module Section
  CONFIG_KEY = 'enabled_sections'

  SIGNUP = :signup
  PUBLIC_DATA = :public_data
  ENROLL = :enroll

  def self.include_section?(section)
    APP_CONFIG[Section::CONFIG_KEY].include?( section.to_s ) ||
      APP_CONFIG[Section::CONFIG_KEY].include?( section )
  end

end
