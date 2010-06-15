# Methods added to this helper will be available to all templates in the application.
module ContentAreasHelper
  def content_area_class(area)
    return 'completed' if area.completed_by?(current_user)
    return 'old_completed' if area.any_version_completed_by?(current_user)
    'available'
  end

  def exam_class(exam)
    return 'completed' if exam.completed_by?(current_user)
    return 'old_completed' if exam.any_version_completed_by?(current_user)
    'available'
  end
end
