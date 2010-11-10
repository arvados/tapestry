class Admin::ScoreboardsController < Admin::AdminControllerBase

  def index 
    @internationalUsers = InternationalParticipant.find_by_sql("SELECT country, count(*) AS count FROM international_participants GROUP BY country ORDER BY count desc")
  end
end
