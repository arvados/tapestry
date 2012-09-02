class PublicGeneticDataController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire
  def index
    @data_type_options = []
    @data_type_options << ['All data types', nil]
    @known_data_type = {}
    UserFile::DATA_TYPES.each { |k,v|
      if v == 'other'
        @data_type_options << [v, v]
      else
        @data_type_options << [k, v]
      end
      @known_data_type[v] = true
    }
    @datasets = UserFile.joins(:user).merge(User.enrolled.not_suspended).includes(:user) |
      Dataset.published.joins(:participant).merge(User.enrolled.not_suspended).includes(:participant)
    if params[:data_type] and !params[:data_type].empty?
      @datasets.reject! { |d|
        ![d.data_type, d.class.to_s].index(params[:data_type]) and
        !(params[:data_type] == 'other' and !@known_data_type[d.data_type])
      }
    end
    @datasets.sort! { |b,a|
      a_date = a.respond_to?(:published_at) ? a.published_at : a.created_at
      b_date = b.respond_to?(:published_at) ? b.published_at : b.created_at
      cmp = a_date <=> b_date
      if cmp != 0 and (a_date - b_date).abs > 3600
        cmp
      elsif a.participant.pgp_id and b.participant.pgp_id
        a.participant.pgp_id <=> b.participant.pgp_id
      elsif a.participant.pgp_id
        -1
      elsif b.participant.pgp_id
        1
      else
        cmp
      end
    }
    respond_to do |format|
      format.html
      format.json {
        respond_with @datasets, :model => Dataset
      }
    end
  end

  def statistics
    @datasets = UserFile.joins(:user).merge(User.enrolled.not_suspended).includes(:user) |
      Dataset.published.joins(:participant).merge(User.enrolled.not_suspended).includes(:participant)
    @data_type_stats = {}
    @data_type_name = {}
    @time_series = {}
    @total_positions_covered = 0
    UserFile::DATA_TYPES.each do |longversion, shortversion|
      @data_type_name[shortversion] = longversion
    end
    @extrapolate_x0 = 1.year.ago
    @extrapolate_y0 = nil
    @datasets.sort_by(&:published_at).each do |d|
      data_type = d.data_type
      data_type = 'other' unless @data_type_name.has_key? data_type
      next unless 0 == @data_type_name[data_type].index('genetic data - ')
      stats = @data_type_stats[data_type] ||= {
        :positions_covered => 0,
        :N => 0
      }
      begin
        @total_positions_covered += d.report_metadata[:called_num]
        stats[:positions_covered] += d.report_metadata[:called_num]
        @extrapolate_x1 = d.published_at
      rescue
        # ignore base-counting fail
      end
      stats[:N] += 1

      @time_series[data_type] ||= {
        'data' => [],
        'label' => data_type + ' datasets'
      }
      @time_series[data_type]['data'] << [(d.published_at.to_f*1000).floor,
                                          stats[:N]]
      @time_series['positions_covered'] ||= {
        'data' => [],
        'label' => 'Positions covered'
      }
      @time_series['positions_covered']['data'] << [(d.published_at.to_f*1000).floor,
                                                    @total_positions_covered]
      if @extrapolate_y0.nil? and d.published_at >= @extrapolate_x0
        @extrapolate_y0 = @total_positions_covered
      end
    end

    # Extend each @time_series to Time.now
    @time_series.keys.each do |s|
      @time_series[s]['data'] << [Time.now.to_f*1000,
                                  @time_series[s]['data'].last[1]]
    end

    @positions_covered_per_s = ((@total_positions_covered - @extrapolate_y0) /
                                (@extrapolate_x1 - @extrapolate_x0)).floor rescue 0
  end
end
