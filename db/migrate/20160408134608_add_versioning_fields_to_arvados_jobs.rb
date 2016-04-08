class AddVersioningFieldsToArvadosJobs < ActiveRecord::Migration
  def self.up
    add_column(:arvados_jobs, :creator_id, :integer)
    add_column(:arvados_jobs, :updater_id, :integer)
    add_column(:arvados_jobs, :deleted_at, :timestamp)
  end

  def self.down
    remove_column(:arvados_jobs, :creator_id)
    remove_column(:arvados_jobs, :updater_id)
    remove_column(:arvados_jobs, :deleted_at)
  end
end
