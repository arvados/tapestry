module DatatablesResponder
  def to_format
    if get? and
        resource.respond_to?(:as_api_response) and
        (format == :json or format == :xml) and
        resource.respond_to?(:collect) then
      render format => datatables_index
    else
      super
    end
  end

  protected

  def datatables_index
    params = controller.params
    model = options[:model]
    subset = resource || model.scoped

    if params[:iDisplayStart]
      page_start = params[:iDisplayStart].to_i
      page = (1 + page_start / params[:iDisplayLength].to_i).to_i rescue nil
      page ||= 1
      per_page = params[:iDisplayLength] || 10
    else
      page = params[:page] || 1
      per_page = params[:per_page] || 100
    end
    page = [page.to_i, 1].max
    per_page = [per_page.to_i, 100].min
    page_start ||= (page - 1) * per_page

    must_do_custom_sort = false
    sortcol_max = [params[:iSortingCols].to_i - 1, 5].min
    sql_orders = []
    joins = {}
    (0..sortcol_max).each do |sortcol_index|
      # sortcol_index='0' === the first key we're sorting on

      # sortcol === the column we're sorting on (0-based)
      sortcol = params["iSortCol_#{sortcol_index}".to_sym]
      next if !sortcol

      # sortkey === the hash key (property name) of the data we're sorting on
      sortkey = params["mDataProp_#{sortcol}".to_sym]
      next if !sortkey

      # sql_column === the sql expression we're sorting on, or an
      # array: [sql_expression, joins]
      sql_column = model.help_datatables_sort_by(sortkey.to_sym, options)

      if sql_column.class == Array
        sql_column, j = sql_column
        joins.merge!(j) { |k,ov,nv| ov.merge(nv) } if j
        subset = subset.scoped(:include => j) if j
      end
      sql_column = sql_column.to_s
      sql_column = "#{model.table_name}.#{sql_column}" unless sql_column.index('.')
      sql_direction = params["sSortDir_#{sortcol_index}".to_sym] == 'desc' ? 'desc' : 'asc'
      sql_orders.push "#{sql_column} #{sql_direction}"
    end
    sql_order = sql_orders.empty? ? "#{model.table_name}.id asc" : sql_orders.join(',')
    sql_search = '1'
    if (params[:sSearch] and
        params[:sSearch].length > 0 and
        model.respond_to? :help_datatables_search)
      sql_search = model.help_datatables_search(options)
      if sql_search.class == Array
        sql_search, j = sql_search
        joins.merge!(j) { |k,ov,nv| ov.merge(nv) } if j
        subset = subset.scoped(:include => j) if j
      end
    end

    @total = subset.visible_to(options[:for])

    conditions = [ sql_search, { :search => "%#{params[:sSearch]}%" } ]
    @filtered = @total.scoped(:conditions => conditions,
                              :include => joins)

    @selected = @filtered.scoped(:order => sql_order,
                                 :offset => page_start,
                                 :limit => per_page,
                                 :group => "#{model.table_name}.id")

    if model.respond_to? :include_for_api
      # re-fetch the desired records by id, using :include =>
      # model.include_for_api this time; otherwise, ActiveRecord will
      # look up the associations one by one during
      # @selected.each.
      @retrieved = model.scoped(:include => model.include_for_api(options[:api_template]),
                                :conditions => ["#{model.table_name}.id in (?)", @selected.collect{|x|x.id}])
      @retrieved.sort! { |a,b| @selected.index(a) <=> @selected.index(b) }
    else
      @retrieved = @selected
    end

    {
      'aModel' => options[:model_name],
      'sEcho' => params[:sEcho].to_i,
      'iTotalRecords' => @total.size,
      'iTotalDisplayRecords' => @filtered.size,
      'aaData' => @retrieved.as_api_response(options[:api_template])
    }
  end
end
