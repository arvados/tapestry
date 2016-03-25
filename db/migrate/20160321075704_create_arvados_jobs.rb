class CreateArvadosJobs < ActiveRecord::Migration
  def self.up
    create_table :arvados_jobs do |t|
      t.string :uuid
      t.text :oncomplete
      t.text :onerror

      t.timestamps
    end
  end

  def self.down
    drop_table :arvados_jobs
  end
end
