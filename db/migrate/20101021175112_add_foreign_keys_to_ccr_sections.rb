class AddForeignKeysToCcrSections < ActiveRecord::Migration
  def self.up
    add_foreign_key('conditions', 'condition_description_id', 'condition_descriptions')
    add_foreign_key('medications', 'medication_name_id', 'medication_names')
    add_foreign_key('allergies', 'allergy_description_id', 'allergy_descriptions')
    add_foreign_key('procedures', 'procedure_description_id', 'procedure_descriptions')
    add_foreign_key('lab_test_results', 'lab_test_result_description_id', 'lab_test_result_descriptions')
    add_foreign_key('immunizations', 'immunization_name_id', 'immunization_names')
  end

  def self.down
    remove_foreign_key('immunizations', 'immunization_name_id')
    remove_foreign_key('lab_test_results' ,'lab_test_result_description_id')
    remove_foreign_key('procedures', 'procedure_description_id')
    remove_foreign_key('allergies', 'allergy_description_id')
    remove_foreign_key('medications', 'medication_name_id')
    remove_foreign_key('conditions', 'condition_description_id')
  end

  def self.add_foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    execute %{alter table #{from_table} add constraint #{constraint_name}
              foreign key (#{from_column}) references #{to_table}(id) 
              ON DELETE RESTRICT}
  end

  def self.remove_foreign_key(from_table, from_column)
    constraint_name = "fk_#{from_table}_#{from_column}"
    execute %{alter table #{from_table} drop foreign key #{constraint_name}}
  end
end
