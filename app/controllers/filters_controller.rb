class FiltersController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire
  before_filter :ensure_admin   # methods are not yet safe for non-admins!

  def upload
    require 'uri'
    require 'rack/utils'

    target_ids = []
    uploaded_io = params[:file]
    target_class = params[:target_class].constantize or raise Exception.new
    target_id_attribute = params[:target_id_attribute]

    rows = CSV.parse(uploaded_io.read)
    possible = Hash.new
    (0..rows[1].length-1).each { |c| possible[c] = 0 }
    (1..[8,rows.length-1].min).each do |r|
      possible.keys.each do |c|
        v = rows[r][c]
        if v and !v.empty?
          ob = target_class.
            visible_to(current_user).
            send("find_all_by_#{target_id_attribute}".to_sym, v)
          if ob.length == 1
            possible[c] += 1
          end
        end
      end
    end
    possible.keys.each do |c|
      possible.delete c if possible[c] < possible.values.max
    end
    if possible.length == 1
      attr_column = possible.keys[0]
      attr_values = rows.collect { |r| r[attr_column] }
      target_objects = target_class.
        visible_to(current_user).
        where("#{target_id_attribute} in (?)", attr_values)
      target_ids = target_objects.collect &:id

      # summarize what we found, so the user can sanity-check
      target_class_s = target_class.to_s.downcase
      target_class_s = target_class_s.pluralize if target_ids.count != 1
      found = ["#{target_ids.count} #{target_class_s}"]
      n_notfound = rows.count - target_ids.count
      if target_class.visible_to(current_user).where("#{target_id_attribute} in (?)", attr_values[0]).count == 0
        found << "1 header row"
        n_notfound -= 1
      end
      if n_notfound > 0
        found << "#{n_notfound} rows with duplicate or unknown keys"
      end
      flash[:notice] = "Found #{found.join('; ')}."
    else
      flash[:error] = "Error: Could not figure out which column contained #{target_id_attribute} keys. #{possible.inspect}"
    end

    uri = URI(params[:return_to] || back)
    uri.query = Rack::Utils.build_query(:target_ids => target_ids.join('.'))
    return_to = uri.to_s

    redirect_to return_to
  end
end
