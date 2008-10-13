# Methods added to this helper will be available to all templates in the application.
module ContentAreasHelper
  def content_area_class(area)
    return 'current' if area == ContentArea.current_for(current_user)
    return 'completed' if area.completed_by?(current_user)
    'locked'
  end

  def exam_class(exam)
    return 'current' if exam == Exam.current_for(current_user)
    return 'completed' if exam.completed_by?(current_user)
    'locked'
  end
end
