# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :external_blog_post do
    feed_url "MyString"
    posted_at "2012-05-08 12:34:25"
    post_url "MyString"
    title "MyText"
    description "MyText"
  end
end
