class Admin::HomesController < Admin::AdminControllerBase
  ADMIN_RESOURCES = %w(users content_areas exam_definitions)

  def index
    @admin_resources = ADMIN_RESOURCES
  end
end
