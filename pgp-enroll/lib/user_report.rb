require 'gchart'

class UserReport
  def self.users_per_day_chart_url
    days_ago = (Date.today - User.first.created_at.to_date).to_i

    chart = GChart.line do |g|
      g.data = []
      days_ago.downto(0) do |n|
        count = User.count(:all, :conditions => ['created_at <= ?', n.days.ago])
        g.data << count
      end

      g.legend = ["Users"]

      g.width  = 600
      g.height = 150

      g.entire_background = "f4f4f4"

      g.axis(:left) { |a| a.range = 0..User.count }

      g.axis(:bottom) do |a|
        a.labels          = [days_ago, days_ago * 0.75, days_ago * 0.5, days_ago * 0.25, 0]
        a.text_color = :black
      end

      g.title = "Users per day since #{days_ago} days ago"
    end

    chart.to_url
  end
end
