# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bulk_message do
    subject "MyString"
    body "MyText"
  end
end
