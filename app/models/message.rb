class Message

 include ActiveModel::Validations
 include ActiveModel::Conversion
 extend ActiveModel::Naming
  
 attr_accessor :category, :email, :confirm_email, :subject, :message
 
 validates_presence_of :category, :message => ': please choose a topic'
 validates_presence_of :email
 validates_presence_of :confirm_email
 validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
 validates_length_of :subject, :minimum => 5, :maximum => 70
 validates_length_of :message, :minimum => 20

 validates :confirm_email, :inclusion => { :in => ['1'], :message => ': please confirm that your e-mail address is valid' }

 TOPICS = [ ['Genetic Data','Genetic Data'], ['My account','My account'], ['Sample collection','Sample collection'], ['Safety Questionnaire','Safety Questionnaire'], ['Surveys','Surveys'], ['Studies','Studies'], ['Other','Other'] ]

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end

