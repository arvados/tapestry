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

    unless uploaded_io and (uploaded_data = uploaded_io.read)
      flash[:error] = 'No file selected.'
      return redirect_to(:back || params[:return_to])
    end

    rows = begin
             if uploaded_io.original_filename.match(/\.tsv$/i)
               logger.debug "Decided TSV based on filename."
               FasterCSV.parse(uploaded_data, :encoding => 'n', :col_sep => "\t")
             elsif uploaded_io.original_filename.match(/\.csv$/i)
               logger.debug "Decided CSV based on filename."
               FasterCSV.parse(uploaded_data, :encoding => 'n')
             else
               csv_rows = FasterCSV.parse(uploaded_data, :encoding => 'n')
               tsv_rows = FasterCSV.parse(uploaded_data, :encoding => 'n', :col_sep => "\t")
               logger.debug "tsv_rows count #{tsv_rows.count} [0].count #{tsv_rows[0].count} [1].count #{tsv_rows[1].count} csv_rows[0].count #{csv_rows[0].count} [1].count #{csv_rows[1].count}"
               if tsv_rows.count > 1 and
                   tsv_rows[0].count == tsv_rows[1].count and
                   (tsv_rows[0].count > csv_rows[0].count or
                    csv_rows[0].count != csv_rows[1].count)
                 logger.debug "Decided TSV based on column counting."
                 tsv_rows
               else
                 logger.debug "Decided CSV based on column counting."
                 csv_rows
               end
             end
           rescue
             nil
           end
    if !rows or rows.empty?
      flash[:error] = 'Failed to parse CSV file.'
      return redirect_to(:back || params[:return_to])
    end

    target_class = params[:target_class].constantize or raise Exception.new
    @target_id_attribute = params[:target_id_attribute]
    @target_id_attribute_args = []
    @target_id_attribute_args = params[:target_id_attribute_args] if params[:target_id_attribute_args]

    if target_class.method_defined? "normalized_#{@target_id_attribute}".to_sym
      @normalize_attribute = true
      @target_attribute_getter = "normalized_#{@target_id_attribute}".to_sym
    else
      @normalize_attribute = true
      @target_attribute_getter = @target_id_attribute.to_sym
    end
    @searchkey_normalizer = "normalize_#{@target_id_attribute}".to_sym
    @searchkey_normalizer = false unless target_class.respond_to? @searchkey_normalizer

    if !@normalize_attribute and
        @target_id_attribute_args.count == 0 and
        target_class.respond_to? "find_all_by_#{@target_id_attribute}".to_sym
      all_obs = nil
    else
      all_obs = {}
      finder = target_class.visible_to(current_user)
      finder = finder.includes(params[:target_finder_includes].to_sym) if params[:target_finder_includes]
      finder.each { |x|
        k = x.send(@target_attribute_getter, *@target_id_attribute_args)
        if all_obs.has_key?(k) and all_obs[k] != x
          all_obs[k] = nil      # ambiguous key
        else
          all_obs[k] = x
        end
      }
    end

    possible = Hash.new
    (0..rows[1].length-1).each { |c| possible[c] = 0 }
    (1..[300,rows.length-1].min).each do |r|
      # stop when we have a decisively winning column
      break if possible.values.max >= 8 and possible.values.select { |x| x < possible.values.max and possible.values.max - x < 8 }.count == 0
      possible.keys.each do |c|
        v = rows[r][c]
        if v and !v.empty?
          if @searchkey_normalizer
            v = target_class.send(@searchkey_normalizer, v)
          end
          if all_obs
            ob = [all_obs[v]].compact
          else
            ob = target_class.
              visible_to(current_user).
              send("find_all_by_#{@target_id_attribute}".to_sym, v)
          end
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

      if @searchkey_normalizer
        attr_values.map! { |v|
          target_class.send(@searchkey_normalizer, v)
        }
      end
      n_duplicates = nil
      if all_obs
        target_objects = attr_values.collect { |v|
          if all_obs.has_key? v
            all_obs[v]
          else
            logger.debug "Not found: #{v}"
            nil
          end
        }.compact
        target_objects_uniq = target_objects.uniq
        n_duplicates = target_objects.count - target_objects_uniq.count
        target_objects = target_objects_uniq
      else
        target_objects = target_class.
          visible_to(current_user).
          where("#{@target_id_attribute} in (?)", attr_values)
      end
      target_ids = target_objects.collect &:id

      @selection = Selection.new(:spec => { :table => rows },
                                 :targets => target_ids)
      @selection.save!

      # summarize what we found, so the user can sanity-check
      target_class_s = target_class.to_s.downcase
      target_class_s = target_class_s.pluralize if target_ids.count != 1
      found = ["#{target_ids.count} #{target_class_s}"]
      n_notfound = rows.count - target_ids.count
      if all_obs
        if !all_obs[attr_values[0]]
          found << "1 header row"
          n_notfound -= 1
        end
      elsif target_class.
          visible_to(current_user).
          where("#{@target_id_attribute} in (?)", attr_values[0]).count == 0
        found << "1 header row"
        n_notfound -= 1
      end
      if n_duplicates > 0
        found << ("#{n_duplicates} duplicate" + (n_duplicates==1 ? '' : 's'))
      end
      if n_notfound > 0
        found << "#{n_notfound - (n_duplicates or 0)} rows with #{'duplicate, ' unless n_duplicates} ambiguous or unknown keys"
      end
      flash[:notice] = "Found #{found.join('; ')}."
    else
      flash[:error] = "Error: Could not figure out which column contained #{@target_id_attribute} keys. #{possible.inspect}"
    end

    uri = URI(params[:return_to] || :back)
    if @selection
      uri.query = Rack::Utils.build_query(:selection_id => @selection.id)
    end
    return_to = uri.to_s

    redirect_to return_to
  end

end
