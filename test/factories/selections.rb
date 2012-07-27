# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :selection do
    spec "MyText"
    targets "MyText"
    target_type "MyString"
  end
end
