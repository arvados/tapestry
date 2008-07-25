require 'factory_girl'

Factory.define(:user) do |f|
  f.add_attribute         'name', 'Barack Obama' #HACK
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
  f.activated_at          { Time.now }
end

Factory.sequence :email do |n|
  "person#{n}@example.org"
end

