require 'factory_girl'

Factory.define(:user) do |f|
  f.add_attribute         'name', 'Barack Obama'
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
end

Factory.define(:admin_user, :class => User) do |f|
  f.add_attribute         'name', 'Barack Obama'
  f.email                 { Factory.next :email }
  f.password              'password'
  f.password_confirmation 'password'
  f.is_admin              true
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

# Is there a better way?  This enrollment_step is necessary, and torn down before tests.
Factory(:enrollment_step,
        :keyword     => 'signup',
        :title       => 'Consent to take entrance exam',
        :description => 'In this step, you sign up for an account and agree to the mini consent form.')

Factory.define(:enrollment_step_completion) do |f|
  f.user            { |u| u.association :user }
  f.enrollment_step { |e| e.association :enrollment_step }
end

Factory.define(:content_area) do |f|
  f.title       'Content Area Title'
  f.description 'Content Area Description'
end

Factory.define(:exam) do |f|
  f.content_area { |e| e.association :content_area }
end

Factory.define(:exam_version) do |f|
  f.title       'Exam Definition Title'
  f.description 'Exam Definition Description'
  f.exam        { |e| e.association :exam }
  f.version 1
end

Factory.define(:exam_response) do |f|
  f.user         { |u| u.association :user }
  f.exam_version { |e| e.association :exam_version }
end

Factory.define(:multiple_choice_exam_question) do |f|
  f.exam_version  { |e| e.association :exam_version }
  f.ordinal       { |q| q.exam_version.exam_questions.count }
end

Factory.define(:check_all_exam_question) do |f|
  f.exam_version  { |e| e.association :exam_version }
  f.ordinal       { |q| q.exam_version.exam_questions.count }
end

Factory.define(:answer_option) do |f|
  f.exam_question { |q| q.association :multiple_choice_exam_question }
  f.answer 'Answer Option'
  f.correct false
end

Factory.define(:question_response) do |f|
  f.answer_option { |a| a.association :answer_option }
  f.exam_response { |r| r.association(:exam_response, :exam_version => r.answer_option.exam_question.exam_version) }
end
