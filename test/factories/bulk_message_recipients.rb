# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bulk_message_recipients do
    bulk_message nil
    user nil
  end
end
