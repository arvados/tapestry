require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :enrollment_step_completions
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step
  has_many :exam_responses

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
                  :first_name, :middle_name, :last_name

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    signup_enrollment_step = EnrollmentStep.find_by_keyword('signup')
    self.complete_enrollment_step(signup_enrollment_step)
    save(false)
  end

  def next_enrollment_step
    last_step_completed = last_completed_enrollment_step

    if last_step_completed.nil?
      EnrollmentStep.first
    else
      EnrollmentStep.find :first, :conditions => ['ordinal > ?', last_step_completed.ordinal]
    end
  end

  def complete_enrollment_step(step)
    raise "enrollment step is nil" if step.nil?
    completion = EnrollmentStepCompletion.new :enrollment_step => step
    enrollment_step_completions << completion 
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
