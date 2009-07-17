require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :enrollment_step_completions
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step
  has_many :exam_responses
  has_one  :residency_survey_response
  has_one  :family_survey_response
  has_one  :privacy_survey_response
  has_one  :informed_consent_response

  has_attached_file :phr

  # temporarily removed requirement
  # attr_accessor :email_confirmation

  validates_presence_of     :first_name
  validates_presence_of     :last_name

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /.+@.+\..+/, :message => MSG_EMAIL_BAD

  # temporarily removed requirement
  # validate_on_create :email_confirmed

  named_scope :has_completed, lambda { |keyword|
    {
      :conditions => ["enrollment_steps.keyword = ?", keyword],
      :joins => :completed_enrollment_steps
    }
  }

  named_scope :inactive, { :conditions => "activated_at IS NULL" }

  named_scope :in_screening_eligibility_group, lambda { |group|
     base_conditions = "residency_survey_responses.us_resident = 1 and
                          residency_survey_responses.can_travel_to_boston = 1 and
                          family_survey_responses.birth_year <= :birth_year and
                          (
                            privacy_survey_responses.worrisome_information_comfort_level = 'always' or
                            privacy_survey_responses.worrisome_information_comfort_level = 'understand'
                          ) and
                          (
                            privacy_survey_responses.information_disclosure_comfort_level = 'comfortable' or
                            privacy_survey_responses.information_disclosure_comfort_level = 'understand'
                          )"

     joins = [:residency_survey_response, :family_survey_response, :privacy_survey_response]
     birth_year = Time.now.year - 21

     if group == 1
       {
         :conditions => ["#{base_conditions} and
                          privacy_survey_responses.past_genetic_test_participation = 'public'
                          ", { :birth_year => birth_year }],
         :joins => joins
       }
     elsif group == 2
       {
         :conditions => ["#{base_conditions} and
                          privacy_survey_responses.past_genetic_test_participation = 'no'
                          ", { :birth_year => birth_year }],
         :joins => joins
       }
     elsif group == 3
       {
         :conditions => ["#{base_conditions} and
                          (
                            privacy_survey_responses.past_genetic_test_participation = 'unsure' or
                            privacy_survey_responses.past_genetic_test_participation = 'yes'
                          )
                          ", { :birth_year => birth_year }],
         :joins => joins
       }
     else
       raise "Undefined screening eligibility group (only 1-3 are defined)"
     end
  }
      # @group1_user = Factory(:user)
      # Factory(:residency_survey_response, :user => @group1_user, :us_resident => true, :can_travel_to_boston => true)
      # Factory(:family_survey_response,    :user => @group1_user, :birth_year => Time.now.year - 25, :monozygotic_twin => 'no')
      # Factory(:privacy_survey_response,   :user => @group1_user, :worrisome_information_comfort_level => 'always',
      #                                                            :information_disclosure_comfort_level => 'comfortable',
      #                                                            :past_genetic_test_participation  => 'public')

  def email=(email)
    email = email.strip if email
    write_attribute(:email, email)
  end

  def has_completed?(keyword)
    !!completed_enrollment_steps.find_by_keyword(keyword)
  end

  # temporarily removed requirement
  #
  # def email_confirmed
  #   unless email_confirmation == email
  #     errors.add(:email, 'must match confirmation')
  #   end
  # end

  def valid_for_attrs?(attrs)
    valid?
    return !attrs.any? { |attr| errors.on(attr) }
  end

  before_create :make_activation_code
  attr_accessible :email, :email_confirmation,
                  :password, :password_confirmation,
                  :first_name, :middle_name, :last_name,
                  :address1, :address2, :city, :state, :zip,
                  :phr_profile_name

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    signup_enrollment_step = EnrollmentStep.find_by_keyword('signup')
    self.complete_enrollment_step(signup_enrollment_step)
    save(false)
  end

  def promote!
    complete_enrollment_step(next_enrollment_step)
  end

  def next_enrollment_step
    last_step_completed = last_completed_enrollment_step

    if last_step_completed.nil?
      EnrollmentStep.ordered.first
    else
      EnrollmentStep.ordered.find :first, :conditions => ['ordinal > ?', last_step_completed.ordinal]
    end
  end

  def complete_enrollment_step(step)
    raise "Cannot find enrollment step to complete." if step.nil?

    if ! EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(self, step)
      completion = EnrollmentStepCompletion.new :enrollment_step => step
      enrollment_step_completions << completion 
    end
  end

  def active?
    activation_code.nil?
  end

  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate email, password
    email = email.strip if email
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def last_completed_enrollment_step
    completed_enrollment_steps.sort_by(&:ordinal).last
  end

  def full_name
    [first_name, middle_name, last_name].join(' ').gsub(/\s+/,' ').strip
  end

  def completed_content_area_count
    ContentArea.all.select { |content_area| content_area.completed_by?(self) }.size
  end

  protected

  def make_activation_code
    self.activation_code = self.class.make_token
  end
end
