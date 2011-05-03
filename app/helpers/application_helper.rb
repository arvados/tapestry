# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end

  def breadcrumb_content
    breadcrumb_list = []
    if @breadcrumbs && @breadcrumbs.any?
      @breadcrumbs[0..-2].each do |txt, path|
        breadcrumb_list << link_to(h(txt), path)
      end
      breadcrumb_list << h(@breadcrumbs.last.first)
      breadcrumb_list.join(' > ')
    else
      ''
    end
  end

  def breadcrumbs
    content = breadcrumb_content
    content.blank? ? '' : <<EOS
      <div id="top-breadcrumbs">
        #{breadcrumb_content}
      </div>
EOS
  end

  def nav_element(text, link)
    content_tag(:li, (current_page?(link) ? {:class => 'current'} : {})) do
      link_to(text, link)
    end
  end

  def display_survey_completion(survey)
    survey.nil? ? 'Not complete' : 'Complete'
  end

  def in_admin_section?
    request.path =~ %r{^/admin/}
  end

  def public_profile_url_string(user)
    return "#{request.protocol}#{ROOT_URL}#{public_profile_path(:hex => user.hex) }"
  end

  # Override error_messages_for to make error messages prettier
  def error_messages_for(*params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'awarning'
        end
      end

      header_message = "Error!"
      error_messages = raw(objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } })

      content_tag(:table,
        content_tag(:tr,
          content_tag(:td,
            content_tag(:div,
              content_tag(:table,
                content_tag(:tr,
                  content_tag(:td, header_message, :class => 'awarninghead')
                  ) <<
                content_tag(:tr,
                  content_tag(:td,
                      raw('The following problem' + (count > 1 ? 's were ' : ' was ') + 'detected:' <<
                      content_tag(:ul, error_messages)),
                    html
                  )
                )
              ), :class => 'awarning'
            ), :align => 'center'
          )
        ), :width => '100%'
      )
    else
      ''
    end
  end
  

end
