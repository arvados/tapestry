# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'uri'
  require 'will_paginate/array'

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
    raw(content)
  end

  def public_data_stats
    Rails.cache.fetch 'public_data_stats' do
      { :publishable_user_count =>
        User.publishable.count,

        :google_survey_response_count =>
        GoogleSurvey.
        where(:is_listed => true).
        collect(&:responses).
        flatten.count,

        :google_survey_respondent_count =>
        GoogleSurvey.
        where(:is_listed => true).
        collect(&:responses).
        flatten.
        collect(&:owner_id).
        uniq.count,

        :google_survey_count =>
        GoogleSurvey.where(:is_listed => true).count,

        :sample_count =>
        Sample.real.no_parent.visible_to(nil).count,

        :published_dataset_count =>
        Dataset.published_or_published_anonymously.count,

        :anonymous_dataset_count =>
        Dataset.published_anonymously.count,

        :user_file_count =>
        UserFile.visible_to(nil).count
      }
    end
  end

  def bootstrap?
    # default to bootstrap, switch to legacy with [any]?bootstrap=0
    (session[:bootstrap] = params[:bootstrap] || session[:bootstrap]) != '0'
  end

  def bootstrap_nav_element(text, link, opts={}, *args)
    if current_page?(link)
      opts = opts.dup
      opts[:class] ||= ''
      opts[:class] += ' active'
    end
    content_tag(:li, opts) do
      link_to(text, link, *args)
    end
  end

  def nav_element(text, link, opts={}, *args)
    if bootstrap?
      return bootstrap_nav_element(text, link, opts, *args)
    end
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
    return "#{ROOT_URL_SCHEME}#{ROOT_URL}#{public_profile_path(:hex => user.hex) }"
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
          html[key] = 'errorExplanation'
        end
      end

      header_message = "Error!"
      header_message = options[:header_message] if options.has_key?(:header_message)
      error_messages = raw(objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } })

      content_tag(:table,
        content_tag(:tr,
          content_tag(:td,
            content_tag(:div,
                  content_tag(:h2, header_message) +
                      content_tag(:ul, error_messages), :id => 'errorExplanation'

            ), :align => 'center'
          )
        ), :width => '100%'
      )
    else
      ''
    end
  end

  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f

    content_for :jstemplates do
      content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
        form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
          x = controller.render_to_string(:partial => options[:partial], :locals => { options[:form_builder_local] => f }.merge(options[:locals] || {}))
          render(:partial => 'layouts/escape_html', :locals => { :html => x })
        end
      end
    end
  end

  def add_child_link(name, association, append_to_selector)
    link_to(name, "javascript:void(0)", :class => "add_child", :"data-association" => association, :"append-to-selector" => append_to_selector)
  end

  def remove_child_link(name, f)
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", :class => "remove_child")
  end

  def uriencode(s)
    URI.escape(s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end

  def uridecode(s)
    URI.unescape(s)
  end

  def n_things(n, thing)
    if n==1
      "1 #{thing}"
    else
      "#{n} #{thing.pluralize}"
    end
  end

  def are_n_things(n, thing)
    if n==1
      "is 1 #{thing}"
    else
      "are #{n} #{thing.pluralize}"
    end
  end

  def humanize_date(t)
    if t < 6.months.ago ||
        (t < 2.months.ago && t.year < Time.now.year) ||
        t > 3.months.from_now ||
        (t > 1.months.from_now && t.year > Time.now.year)
      t.strftime '%B %-d, %Y'
    else
      t.strftime '%B %-d'
    end
  end

  def alert_classes_for_flash_key(key)
    key = key.to_s
    if key == 'warning'
      'alert alert-block'
    elsif key == 'error'
      'alert alert-block alert-error'
    elsif key == 'notice'
      'alert alert-block alert-info'
    else
      'alert alert-block alert-' + key
    end
  end
end
