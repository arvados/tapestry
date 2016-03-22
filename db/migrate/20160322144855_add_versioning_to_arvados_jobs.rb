class AddVersioningToArvadosJobs < ActiveRecord::Migration
  def self.up
    ArvadosJob.create_versioned_table
  end

  def self.down
    ArvadosJob.drop_versioned_table
  end
end
