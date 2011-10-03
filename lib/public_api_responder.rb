module PublicApiResponder
  def to_format
    if get? and
        resource.respond_to?(:as_api_response) and
        (format == :json or
         format == :xml)
      return render format => resource.as_api_response(options[:api_template] || :public)
    end
    super
  end
end
