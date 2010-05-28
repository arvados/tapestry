require 'digest/sha1'
require 'user_eligibility_groupings'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :enrollment_step_completions
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step
  has_many :exam_responses
  has_many :waitlists
  has_many :distinctive_traits
  has_one  :residency_survey_response
  has_one  :family_survey_response
  has_one  :privacy_survey_response
  has_one  :informed_consent_response
  has_one  :baseline_traits_survey
  has_and_belongs_to_many :mailing_lists, :join_table => :mailing_list_subscriptions

  has_attached_file :phr

  # temporarily removed requirement
  # attr_accessor :email_confirmation

  validates_presence_of     :first_name
  validates_presence_of     :last_name

  validates_presence_of     :security_question
  validates_length_of       :security_question, :minimum => 5
  validates_presence_of     :security_answer
  validates_length_of       :security_answer, :minimum => 2

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
     joins = [:residency_survey_response, :family_survey_response, :privacy_survey_response, :enrollment_step_completions]
     birth_year = Time.now.year - 21
     # content_areas_enrollment_step_id = EnrollmentStep.find_by_keyword('content_areas').id
     eligibility_step_id = EnrollmentStep.find_by_keyword('screening_submission').id
     promoted_or_waitlisted_ids = User.promoted_ids | User.waitlisted_ids

     conditions_sql = UserEligibilityGroupings.eligibility_group_sql(group)
     conditions_sql += " and users.id not in (:promoted_or_waitlisted_ids)"

     {
       :conditions => [conditions_sql, {
           :birth_year => birth_year,
           :eligibility_step_id => eligibility_step_id,
           :promoted_or_waitlisted_ids => promoted_or_waitlisted_ids
          }],
       :joins => joins
     }
  }

  def self.promoted_ids
    step_id = EnrollmentStep.find_by_keyword('eligibility_screening_results').id
    connection.select_values("select users.id from users
        inner join enrollment_step_completions on enrollment_step_completions.user_id = users.id
        where enrollment_step_completions.enrollment_step_id = #{step_id}")
  end

  def self.waitlisted_ids
    connection.select_values("select users.id from users
        inner join waitlists on waitlists.user_id = users.id
        where waitlists.resubmitted_at is null")
  end

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
                  :security_question, :security_answer,
                  :address1, :address2, :city, :state, :zip,
                  :phr_profile_name, :mailing_list_ids

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

  def last_waitlisted_at
    waitlists.first(:order => 'created_at desc').created_at if waitlists.any?
  end

  protected

  def make_activation_code
    self.activation_code = self.class.make_token
  end
end
