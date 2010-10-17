class Admin::PhrReportsController < Admin::AdminControllerBase
  include PhrccrsHelper

  def index
    @race_options = ['American Indian or Alaska Native',
      'Asian',
      'Black or African American',
      'Hispanic/Latino',
      'Native Hawaiian or Other Pacific Islander',
      'White']

    @gender_options = ['Female', 'Male']

    @condition_options = Condition.find(:all, :select => 'DISTINCT description', :order => 'description')

    queries = []
    query_params = []
    joins = []

    race_filter_sql = ''
    if !params['race_filter'].nil?
      params['race_filter'].each {|race|
        if race_filter_sql != ''
          race_filter_sql += " OR race LIKE ?"
        else
          race_filter_sql += "race LIKE ?"
        end
          query_params << '%' + race + '%'
      }
    end
    queries << race_filter_sql unless race_filter_sql.empty?
    joins << 'INNER JOIN demographics ON demographics.ccr_id = ccrs.id' unless race_filter_sql.empty?

    gender_filter_sql = ''
    if !params['gender_filter'].nil?
      params['gender_filter'].each {|gender|
        if gender_filter_sql != ''
          gender_filter_sql += " OR gender = ?"
        else
          gender_filter_sql += "gender = ?"
        end
        query_params << gender
      }
    end
    queries << gender_filter_sql unless gender_filter_sql.empty?
    joins << 'INNER JOIN demographics ON demographics.ccr_id = ccrs.id' if !gender_filter_sql.empty? && race_filter_sql.empty?

    family_relationship_filter_sql = ''
    if !params['has_family_members_enrolled'].nil?
      family_relationship_filter_sql = "has_family_members_enrolled = 'yes'"
    end
    queries << family_relationship_filter_sql unless family_relationship_filter_sql.empty?
    joins << 'INNER JOIN users ON users.id = ccrs.user_id' unless family_relationship_filter_sql.empty?

    condition_inner_sql = "ccrs.id IN (SELECT ccrs.id FROM ccrs INNER JOIN conditions ON ccrs.id = conditions.ccr_id WHERE "
    condition_filter_sql = ''
    if !params['condition_filter'].nil?
      params['condition_filter'].each {|condition|
        if condition_filter_sql != ''
          condition_filter_sql += " OR conditions.description = ?"
        else
          condition_filter_sql += "conditions.description = ?"
        end
        query_params << condition
      }
    end
    queries << condition_inner_sql + condition_filter_sql + ')' unless condition_filter_sql.empty?
    #flash[:notice] = '(' + queries.join(') AND (') + ')'

    @ccrs = []
    unless params[:commit].nil? or queries.empty? or query_params.empty? 
      ccr_results = Ccr.find(:all, :joins => joins.join(' '), :conditions => ['(' + queries.join(') AND (') + ')', query_params].flatten, :order => 'id, version')
      current_user_id = 0
      ccr_results.each {|ccr|
        if ccr.user_id != current_user_id
          @ccrs << ccr
        end
        current_user_id = ccr.user_id
      }
    end
  end
end
