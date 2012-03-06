class RenameGeneticDataToUserFiles< ActiveRecord::Migration
    def self.up
        rename_table :genetic_data, :user_files
        rename_table :genetic_data_versions, :user_file_versions
        rename_column :user_file_versions, :genetic_data_id, :user_file_id
    end 
    def self.down
        rename_column :user_file_versions, :user_file_id, :genetic_data_id
        rename_table :user_file_versions, :genetic_data_versions
        rename_table :user_files, :genetic_data
    end
 end
