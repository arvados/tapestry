module Admin::UsersHelper
  def csv_for_users(users)
    fields = %w(name email activated_at)
    buf = ''

    CSV.generate_row(fields.map(&:humanize), fields.size, buf)
    users.each do |user|
      CSV.generate_row(fields.map {|f| user.send(f) }, fields.size, buf)
    end

    buf
  end
end

