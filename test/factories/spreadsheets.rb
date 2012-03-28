# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :spreadsheet do
    user nil
    name "MyString"
    description "MyText"
    rowtarget_class "MyString"
    rowtarget_id_attribute "MyString"
    rowtarget_data_attribute "MyString"
    row_id_column 1
    auto_update_interval 1
    is_auto_update_enabled false
    last_downloaded_at "2012-03-27 15:50:33"
  end
end
