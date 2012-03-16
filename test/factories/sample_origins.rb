# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sample_origin do
    parent_sample nil
    child_sample nil
    derivation_method "MyString"
  end
end
