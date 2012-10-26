class PublicGeneticDataController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  def anonymous
    # Only return anonymous genetic data for which the owner has taken all trait surveys

    users = Array.new()

    # Make a list of every participant that has taken each trait survey
    TRAIT_SURVEY_IDS.each do |ts_id|
      if users.empty? then
        users = Nonce.where("target_class=? and target_id = ?",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      else
        users = users & Nonce.where("target_class=? and target_id = ?",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      end
    end

    # Now get the anonymous datasets, and limit them to those users for which we have trait survey results 
    @datasets = Dataset.published_anonymously.joins(:participant).merge(User.enrolled.not_suspended).includes(:participant).where('participant_id in (?)',users)

    index_worker(:published_anonymously_at)
  end

  def index
    @datasets = UserFile.joins(:user).merge(User.enrolled.not_suspended).includes(:user) |
      Dataset.published.joins(:participant).merge(User.enrolled.not_suspended).includes(:participant)
    index_worker(:published_at)
  end

  def index_worker(sort_column)
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
    if params[:data_type] and !params[:data_type].empty?
      @datasets.reject! { |d|
        ![d.data_type, d.class.to_s].index(params[:data_type]) and
        !(params[:data_type] == 'other' and !@known_data_type[d.data_type])
      }
    end
    @datasets.sort! { |b,a|
      a_date = a.respond_to?(sort_column) ? a.send(sort_column) : a.created_at
      b_date = b.respond_to?(sort_column) ? b.send(sort_column) : b.created_at
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
    @coverage_series = {}
    @participants_series = {}
    @t0 = nil
    UserFile::DATA_TYPES.each do |longversion, shortversion|
      @data_type_name[shortversion] = longversion
    end
    @datasets.sort_by(&:published_at).each do |d|
      data_type = d.data_type
      data_type = 'other' unless @data_type_name.has_key? data_type
      next unless 0 == @data_type_name[data_type].index('genetic data - ')
      stats = @data_type_stats[data_type] ||= {
        :positions_covered => 0,
        :n_datasets => 0,
        :participants => {}
      }
      add_to_coverage_series = false
      begin
        stats[:positions_covered] += d.report_metadata[:called_num]
        add_to_coverage_series = true
      rescue
        # ignore base-counting fail
      end
      stats[:n_datasets] += 1

      @t0 ||= (d.published_at.to_f*1000).floor

      @participants_series[data_type] ||= {
        'data' => [[@t0, 0]],
        'label' => data_type,
        'data_type' => data_type
      }
      stats[:participants][d.participant.hex] = true
      @participants_series[data_type]['data'] << [(d.published_at.to_f*1000).floor,
                                                  @participants_series[data_type]['data'].last[1]]
      @participants_series[data_type]['data'] << [(d.published_at.to_f*1000).floor,
                                                  stats[:participants].size]

      if add_to_coverage_series
        @coverage_series[data_type] ||= {
          'data' => [[@t0, 0]],
          'label' => data_type,
          'data_type' => data_type
        }
        @coverage_series[data_type]['data'] << [(d.published_at.to_f*1000).floor,
                                                @coverage_series[data_type]['data'].last[1]]
        @coverage_series[data_type]['data'] << [(d.published_at.to_f*1000).floor,
                                                stats[:positions_covered]]
      end
    end

    # Extend each series to Time.now and sort by total coverage
    @participants_series, @coverage_series = [@participants_series, @coverage_series].collect do |series|
      series.keys.each do |s|
        series[s]['data'] << [Time.now.to_f*1000,
                              series[s]['data'].last[1]]
      end
      series.values.sort_by { |s|
        begin
          0-@coverage_series[s['data_type']]['data'].last[1]
        rescue
          2**32 - s['data'].last[1]
        end
      }
    end
  end
end
