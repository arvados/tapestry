# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :permission do
    action "MyString"
    subject_class "MyString"
    subject_id 1
  end
end
