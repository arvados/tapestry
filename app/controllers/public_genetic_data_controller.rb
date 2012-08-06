class PublicGeneticDataController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire
  def index
    @data_type_options = []
    @data_type_options << ['All data types', nil]
    @data_type_options << ['Whole genome', 'Whole genome']
    UserFile::DATA_TYPES.each { |k,v|
      if v == 'other'
        @data_type_options << [v, v]
      else
        @data_type_options << [k, v]
      end
    }
    @datasets = UserFile.joins(:user).merge(User.enrolled.not_suspended) |
      Dataset.published.joins(:participant).merge(User.enrolled.not_suspended)
    if params[:data_type] and !params[:data_type].empty?
      @datasets.reject! { |d|
        ![d.data_type, d.class.to_s].index(params[:data_type])
      }
    end
    @datasets.sort! { |b,a|
      (a.respond_to?(:published_at) ? a.published_at : a.created_at) <=>
      (b.respond_to?(:published_at) ? b.published_at : b.created_at)
    }
  end
end
