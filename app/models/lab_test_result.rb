class LabTestResult < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

      belongs_to :ccr
      belongs_to :lab_test_result_description

  def description
    if not lab_test_result_description.nil? then 
      lab_test_result_description.description
    else
      ''
    end
  end
end
