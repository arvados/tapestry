class LabTestResult < ActiveRecord::Base
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
