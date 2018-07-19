class PublicGeneticDataController < ApplicationController
  before_filter      {|c| c.check_section_disabled(Section::PUBLIC_DATA) }
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  include PublicGeneticDataHelper

  def anonymous
    # Only return anonymous genetic data for which the owner has taken all trait surveys

    users = Array.new()

    # Make a list of every participant that has taken each trait survey
    TRAIT_SURVEY_IDS.each do |ts_id|
      if users.empty? then
        users = Nonce.where("target_class=? and target_id = ? and used_at is not null",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      else
        users = users & Nonce.where("target_class=? and target_id = ? and used_at is not null",'GoogleSurvey',ts_id).map { |n| n.owner_id }
      end
    end

    # Now get the anonymous datasets, and limit them to those users for which we have trait survey results
    @datasets = Dataset.published_anonymously.joins(:participant).merge(User.enrolled.not_suspended).includes(:participant).where('participant_id in (?)',users)

    index_worker(:published_anonymously_at)
  end

  def index
    @datasets = UserFile.downloadable.joins(:user).merge(User.enrolled.not_suspended).includes(:user) |
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
    # View rendering is absurdly slow on this page, because we don't paginate.
    # Make it cache friendly.
    expires_in(1.day, :public => true)
    if stale?(etag: @datasets)
      respond_to do |format|
        format.html
        format.json {
          respond_with @datasets.collect { |user_file_or_dataset|
            if user_file_or_dataset.class == UserFile
              download_url = user_file_download_url(user_file_or_dataset)
            elsif user_file_or_dataset.download_url
              download_url = user_file_or_dataset.download_url
            else
              download_url = nil
            end
            user_file_or_dataset.attributes.delete_if { |k,v|
               not ['data_type', 'name', 'date', 'description', 'report_url'].include?(k)
            }.merge({
              'file_source' => user_file_or_dataset.class.name == 'UserFile' ? 'Participant' : 'PGP',
              'download_url' => download_url
            })
          }
        }
      end
    end
  end

  def statistics
    @data_type_stats = {}
    @data_type_name = {}
    @coverage_series = {}
    @participants_series = {}

    @datasets = UserFile.select('user_files.id, user_files.created_at, user_files.user_id, user_files.data_type, user_files.report_metadata').joins(:user).merge(User.enrolled.not_suspended).includes(:user) |
      Dataset.published.select('datasets.id, datasets.published_at, datasets.published_anonymously_at, datasets.participant_id, datasets.name, datasets.report_metadata').joins(:participant).merge(User.enrolled.not_suspended).includes(:participant) |
      Dataset.published_anonymously.select('datasets.id, datasets.published_at, datasets.published_anonymously_at, datasets.participant_id, datasets.name, datasets.report_metadata').joins(:participant).merge(User.enrolled.not_suspended).includes(:participant)
    @sorted_datasets = @datasets.sort_by { |d| d.published_at.nil? ? d.published_anonymously_at : d.published_at }
    @sorted_users = User.enrolled.select(:enrolled).order('enrolled')
    @sorted_sample_logs = SampleLog.where('comment like ?', '%received by researcher%').select('sample_logs.created_at, sample_logs.sample_id').joins(:sample).merge(Sample.with_participant).includes(:sample).order('sample_logs.created_at').group('samples.participant_id').map(&:created_at)

    #@t0 = User.enrolled.minimum(:enrolled) ||
    @t0 = @sorted_users.first.enrolled ||
      @sorted_datasets.first.published_at ||
      @sorted_datasets.first.published_anonymously_at

    @participants_series[:enrolled] ||= {
      'data' => [[jstime(@t0), 0]],
      'label' => 'Participants enrolled',
      'data_type' => 'enrolled',
      'lines' => { 'show' => true, 'fill' => 0.2 }
    }

    @sorted_users.each do |user|
      @participants_series[:enrolled]['data'] << [jstime(user.enrolled),
                                                  @participants_series[:enrolled]['data'].last[1]]
      @participants_series[:enrolled]['data'] << [jstime(user.enrolled),
                                                  @participants_series[:enrolled]['data'].last[1] + 1]
    end

    @counted_participant = {}

    @participants_series[:with_samples] ||= {
      'data' => [[jstime(@t0), 0]],
      'label' => 'Participants with samples collected',
      'data_type' => 'with_samples',
      'lines' => { 'show' => true, 'fill' => 0.2 }
    }

    @sorted_sample_logs.each do |created_at|
      @participants_series[:with_samples]['data'] << [jstime(created_at),
                                                      @participants_series[:with_samples]['data'].last[1]]
      @participants_series[:with_samples]['data'] << [jstime(created_at),
                                                      @participants_series[:with_samples]['data'].last[1] + 1]
    end

    UserFile::DATA_TYPES.each do |longversion, shortversion|
      @data_type_name[shortversion] = longversion
    end
    @sorted_datasets.each do |d|
      published_at = d.published_at
      published_at = d.published_anonymously_at if d.published_at.nil?
      data_type = d.data_type
      data_type = 'other' unless @data_type_name.has_key? data_type
      next unless 0 == @data_type_name[data_type].index('genetic data - ')
      stats = @data_type_stats[data_type] ||= {
        :positions_covered => 0,
        :n_datasets => 0,
        :participants => {},
        :participants_with_wgs => {}
      }
      add_to_coverage_series = false
      add_to_wgs_series = false
      if not d.report_metadata.nil?
        begin
          stats[:positions_covered] += d.report_metadata[:called_num]
          add_to_coverage_series = true
          if d.report_metadata[:called_num] > 1000000000
            add_to_wgs_series = true
            stats[:participants_with_wgs][d.participant.hex] = true
          end
        rescue
          # ignore base-counting fail
        end
      end
      stats[:n_datasets] += 1

      @participants_series[data_type] ||= {
        'data' => [[jstime(@t0), 0]],
        'label' => data_type,
        'data_type' => data_type
      }
      stats[:participants][d.participant.hex] = true
      @participants_series[data_type]['data'] << [jstime(published_at),
                                                  @participants_series[data_type]['data'].last[1]]
      @participants_series[data_type]['data'] << [jstime(published_at),
                                                  stats[:participants].size]

      if add_to_coverage_series
        @coverage_series[data_type] ||= {
          'data' => [[jstime(@t0), 0]],
          'label' => data_type,
          'data_type' => data_type
        }
        @coverage_series[data_type]['data'] << [jstime(published_at),
                                                @coverage_series[data_type]['data'].last[1]]
        @coverage_series[data_type]['data'] << [jstime(published_at),
                                                stats[:positions_covered]]
      end

      if add_to_wgs_series
        @participants_series[:with_wgs] ||= {
          'data' => [[jstime(@t0), 0]],
          'label' => 'Participants with published WGS data',
          'data_type' => 'with_wgs',
          'lines' => { 'show' => true, 'fill' => 0.2 }
        }
        @participants_series[:with_wgs]['data'] << [jstime(published_at),
                                                    @participants_series[:with_wgs]['data'].last[1]]
        @participants_series[:with_wgs]['data'] << [jstime(published_at),
                                                    stats[:participants_with_wgs].size]
      end
    end

    @samples_series = {
      :enrolled => @participants_series.delete(:enrolled),
      :with_samples => @participants_series.delete(:with_samples),
      :with_wgs => @participants_series.delete(:with_wgs)
    }

    # Extend each series to Time.now and sort by total coverage
    @participants_series, @coverage_series, @samples_series = [@participants_series, @coverage_series, @samples_series].collect do |series|
      series.keys.each do |s|
        next if not series[s] or not series[s].has_key?('data')
        series[s]['data'] << [jstime(Time.now),
                              series[s]['data'].last[1]]
      end
      series.values.compact.sort_by { |s|
        begin
          0-@coverage_series[s['data_type']]['data'].last[1]
        rescue
          2**32 - s['data'].last[1]
        end
      }
    end
  end
end
