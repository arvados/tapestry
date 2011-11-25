class PermissionObserver < ActiveRecord::Observer
  observe :plate, :kit, :sample

  # Make sure to remove permissions that refer to deleted objects
  def after_destroy(record)
    Permission.find_all_by_subject_class(record.class).each do |p|
      p.destroy if p.subject_id == record.id
    end
  end

end
