class LabTestResult < ActiveRecord::Base
      belongs_to :ccr
      belongs_to :lab_test_result_description

  def description
    lab_test_result_description.description
  end
end
