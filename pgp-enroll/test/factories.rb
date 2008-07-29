require 'factory_girl'

Factory.define(:user) do |f|
  f.add_attribute         'name', 'Barack Obama' #HACK
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
  f.activated_at          { Time.now }
end

Factory.sequence(:email) { |n| "person#{n}@example.org" }

Factory.sequence(:enrollment_step_ordinal) { |n| n }

%w(keyword title description).each do |attr|
  Factory.sequence("enrollment_step_#{attr}".to_sym) { |n| "#{attr.upcase} #{n}" }
end


Factory.define(:enrollment_step) do |f|
  f.keyword     { Factory.next :enrollment_step_keyword }
  f.ordinal     { Factory.next :enrollment_step_ordinal }
  f.title       { Factory.next :enrollment_step_title   }
  f.description { Factory.next :enrollment_step_description }
end
