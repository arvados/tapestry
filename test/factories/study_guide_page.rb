# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :study_guide_page do
    exam_version nil
    ordinal 1
    contents "MyText"
  end
end
