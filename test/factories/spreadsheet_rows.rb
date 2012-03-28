# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :spreadsheet_row do
    spreadsheet nil
    row_number 1
    text ""
  end
end
