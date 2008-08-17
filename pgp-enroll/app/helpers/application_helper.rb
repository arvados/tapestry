# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_standard_flashes(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
    elsif flash[:error]
      level = 'error'
      if flash[:error].instance_of? ActiveRecord::Errors
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    flash.discard # TODO is this the best way to handle recurring flashes?
    content_tag 'div', flash_to_display, :class => "flash #{level}"
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end

  def breadcrumbs
    breadcrumb_list = []
    if @breadcrumbs
      @breadcrumbs[0..-2].each do |txt, path|
        breadcrumb_list << link_to(h(txt), path)
      end
    end
    breadcrumb_list << h(@breadcrumbs.last.first)
    breadcrumb_list.join(' > ')
  end
end
