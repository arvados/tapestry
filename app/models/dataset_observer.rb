class DatasetObserver < ActiveRecord::Observer

  def assign_pgp_id(dataset)
    @u = dataset.participant
    if (not dataset.published_at.nil? or not dataset.published_anonymously_at.nil?) and @u.pgp_id.nil? then
      @u.assign_pgp_id
    end
  end

  def after_save(dataset)
    assign_pgp_id(dataset)
  end

  def after_create(dataset)
    assign_pgp_id(dataset)
  end

end
