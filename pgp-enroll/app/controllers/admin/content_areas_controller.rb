class Admin::ContentAreasController < Admin::AdminControllerBase
  def index
    @content_areas = ContentArea.all
  end
end

