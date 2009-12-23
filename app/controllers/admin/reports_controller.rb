class Admin::ReportsController < Admin::AdminControllerBase

  def index
    @passed_entrance_exam_count = User.has_completed('content_areas').count
    @content_areas = ContentArea.all
  end

end
