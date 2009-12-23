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
end
