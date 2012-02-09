# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :report do
    name "MyString"
    type "MyString"
    requested "2012-02-09 16:47:28"
    created "2012-02-09 16:47:28"
    user nil
    path "MyString"
  end
end
